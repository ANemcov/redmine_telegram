require 'httpclient'

class TelegramListener < Redmine::Hook::Listener

  def speak(msg, channel, attachment=nil, token=nil)
    proxyurl = Setting.plugin_redmine_telegram['proxyurl']
    token = Setting.plugin_redmine_telegram['telegram_bot_token'] if not token
    url = "https://api.telegram.org/bot#{token}/sendMessage"

    params = {}
    params[:chat_id] = channel if channel
    params[:parse_mode] = "HTML"
    params[:disable_web_page_preview] = 1

    if attachment
      msg = msg +"\r\n"
      msg = msg +attachment[:text] if attachment[:text]
      for field_item in attachment[:fields] do
        msg = msg +"\r\n"+"<b>"+field_item[:title]+":</b> "+field_item[:value]
      end
    end

    params[:text] = msg

    Rails.logger.info("TELEGRAM GLOBAL SEND TO: #{channel}")
    Rails.logger.info("TELEGRAM GLOBAL TOKEN EMPTY, PLEASE SET IT IN PLUGIN SETTINGS") if token.nil? || token.empty?

    Thread.new do
      retries = 0
      begin
        if Setting.plugin_redmine_telegram['use_proxy'] == '1'
          client = HTTPClient.new(proxyurl)
        else
          client = HTTPClient.new
        end
        client.connect_timeout = 2
        client.send_timeout = 2
        client.receive_timeout = 2
        client.keep_alive_timeout = 2
        client.ssl_config.timeout = 2
        conn = client.post_async(url, params)
        Rails.logger.info("TELEGRAM GLOBAL SEND CODE: #{conn.pop.status_code}")
      rescue Exception => e
        Rails.logger.warn("TELEGRAM GLOBAL CANNOT CONNECT TO #{url} RETRY ##{retries}, ERROR #{e}")
        retry if (retries += 1) < 5
      end
    end

  end

  def controller_issues_new_after_save(context={})
    issue = context[:issue]
    channel = channel_for_project issue.project
    token = token_for_project issue.project
    priority_id = 1
    priority_id = Setting.plugin_redmine_telegram['priority_id_add'].to_i if Setting.plugin_redmine_telegram['priority_id_add'].present?

    return unless channel

    # we dont care about any privacy, right? if not - uncomment it:
    # return if issue.is_private?

    msg = "<b>[#{escape issue.project}]</b>\n<a href='#{object_url issue}'>#{escape issue}</a> #{mentions issue.description if Setting.plugin_redmine_telegram['auto_mentions'] == '1'}\n<b>#{escape issue.author}</b> #{l(:field_created_on)}\n"

    attachment = {}
    attachment[:text] = escape issue.description if issue.description
    attachment[:fields] = [{
      :title => I18n.t("field_status"),
      :value => escape(issue.status.to_s),
      :short => true
    }, {
      :title => I18n.t("field_priority"),
      :value => escape(issue.priority.to_s),
      :short => true
    }, {
      :title => I18n.t("field_assigned_to"),
      :value => escape(issue.assigned_to.to_s),
      :short => true
    }]
    attachment[:fields] << {
      :title => I18n.t("field_watcher"),
      :value => escape(issue.watcher_users.join(', ')),
      :short => true
    } if Setting.plugin_redmine_telegram['display_watchers'] == 'yes'

    unless issue.tracker_id.to_s or issue.author_id.to_s
      speak msg, channel, attachment, token if issue.priority_id.to_i >= priority_id
    end

  end

  def controller_issues_edit_after_save(context={})
    issue = context[:issue]
    journal = context[:journal]
    channel = channel_for_project issue.project
    token = token_for_project issue.project
    priority_id = 1
    priority_id = Setting.plugin_redmine_telegram['priority_id_add'].to_i if Setting.plugin_redmine_telegram['priority_id_add'].present?

    return unless channel and Setting.plugin_redmine_telegram['post_updates'] == '1'

    # we dont care about any privacy, right? if not - uncomment it:
    # return if issue.is_private?
    # return if journal.private_notes?

    msg = "<b>[#{escape issue.project}]</b>\n<a href='#{object_url issue}'>#{escape issue}</a> #{mentions journal.notes if Setting.plugin_redmine_telegram['auto_mentions'] == '1'}\n<b>#{journal.user.to_s}</b> #{l(:field_updated_on)}"

    attachment = {}
    attachment[:text] = escape journal.notes if journal.notes
    attachment[:fields] = journal.details.map { |d| detail_to_field d }

    unless issue.tracker_id.to_s or journal.user_id.to_s
      speak msg, channel, attachment, token if issue.priority_id.to_i >= priority_id
    end

  end

private
  def escape(msg)
    msg.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("[", "\[").gsub("]", "\]").gsub("&lt;pre&gt;", "<code>").gsub("&lt;/pre&gt;", "</code>")
  end

  def object_url(obj)
    if Setting.host_name.to_s =~ /\A(https?\:\/\/)?(.+?)(\:(\d+))?(\/.+)?\z/i
      host, port, prefix = $2, $4, $5
      Rails.application.routes.url_for(obj.event_url({
        :host => host,
        :protocol => Setting.protocol,
        :port => port,
        :script_name => prefix
      }))
    else
      Rails.application.routes.url_for(obj.event_url({
        :host => Setting.host_name,
        :protocol => Setting.protocol
      }))
    end
  end

  def token_for_project(proj)
    return nil if proj.blank?

    cf = ProjectCustomField.find_by_name("Telegram BOT Token")

    return [
        (proj.custom_value_for(cf).value rescue nil),
        # dont want to check parent projects for token, if now - uncomment:
        # (channel_for_project proj.parent),
        Setting.plugin_redmine_telegram['telegram_bot_token'],
    ].find{|v| v.present?}
  end

  def channel_for_project(proj)
    return nil if proj.blank?

    cf = ProjectCustomField.find_by_name("Telegram Channel")

    val = [
      (proj.custom_value_for(cf).value rescue nil),
      # dont want to check parent projects for channel, if now - uncomment:
      # (channel_for_project proj.parent),
      Setting.plugin_redmine_telegram['channel'],
    ].find{|v| v.present?}

    # Channel name '-' is reserved for NOT notifying
    return nil if val.to_s == '-'
    val
  end

  def detail_to_field(detail)
    if detail.property == "cf"
      key = CustomField.find(detail.prop_key).name rescue nil
      title = key
    elsif detail.property == "attachment"
      key = "attachment"
      title = I18n.t :label_attachment
    else
      key = detail.prop_key.to_s.sub("_id", "")
      title = I18n.t "field_#{key}"
    end

    short = true
    value = escape detail.value.to_s

    case key
    when "title", "subject", "description"
      short = false
    when "tracker"
      tracker = Tracker.find(detail.value) rescue nil
      value = escape tracker.to_s
    when "project"
      project = Project.find(detail.value) rescue nil
      value = escape project.to_s
    when "status"
      status = IssueStatus.find(detail.value) rescue nil
      value = escape status.to_s
    when "priority"
      priority = IssuePriority.find(detail.value) rescue nil
      value = escape priority.to_s
    when "category"
      category = IssueCategory.find(detail.value) rescue nil
      value = escape category.to_s
    when "assigned_to"
      user = User.find(detail.value) rescue nil
      value = escape user.to_s
    when "fixed_version"
      version = Version.find(detail.value) rescue nil
      value = escape version.to_s
    when "attachment"
      attachment = Attachment.find(detail.prop_key) rescue nil
      value = "#{object_url attachment}" if attachment
    when "parent"
      issue = Issue.find(detail.value) rescue nil
      value = "#{object_url issue}" if issue
    end

    value = " - " if value.empty?

    result = { :title => title, :value => value }
    result[:short] = true if short
    result
  end

  def mentions text
    names = extract_usernames text
    names.present? ? "\nTo: " + names.join(', ') : nil
  end

  def extract_usernames text = ''
    if text.nil?
      text = ''
    end

    # Telegram usernames may only contain lowercase letters, numbers,
    # dashes and underscores and must start with a letter or number.
    text.scan(/@[a-z0-9][a-z0-9_\-]*/).uniq
  end
end

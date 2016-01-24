require 'httpclient'

require_dependency 'mailer'

module TelegramMailerPatch
  def self.included(base) # :nodoc:
    
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :issue_add, :telegram
    end
  end
  
  module ClassMethods
    
    def speak(msg, channel, attachment=nil, url=nil)
      Rails.logger.info("TELEGRAM SPEAK")
      url = Setting.plugin_redmine_telegram[:telegram_bot_token] if not url
      username = Setting.plugin_redmine_telegram[:username]
      icon = Setting.plugin_redmine_telegram[:icon]

      telegram_url = 'https://api.telegram.org/bot'+url+"/sendMessage"

      params = {}
      

      params[:chat_id] = channel if channel
      params[:parse_mode] = "Markdown"
      
      # if icon and not icon.empty?
      #   if icon.start_with? ':'
      #     params[:icon_emoji] = icon
      #   else
      #     params[:icon_url] = icon
      #   end
      # end
      
      if attachment
        msg = msg +"\r\n"+attachment[:text]
        for field_item in attachment[:fields] do
          msg = msg +"\r\n"+"> *"+field_item[:title]+":* "+field_item[:value]
        end
      end

      params[:text] = msg
      
      begin
        client = HTTPClient.new
        # client.ssl_config.cert_store.set_default_paths
        # client.ssl_config.ssl_version = "SSLv23"
        # client.post_async url, {:payload => params.to_json}
        client.post_async(telegram_url, params)
      rescue
        # Bury exception if connection error
      end
    end

  end
  
  module InstanceMethods
    # Adds a rates tab to the user administration page
    def issue_add_with_telegram(issue, to_users, cc_users)
      Rails.logger.info("TELEGRAM [#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}")
      issue_add_without_telegram(issue, to_users, cc_users)
    end

  end
end

Mailer.send(:include, TelegramMailerPatch)
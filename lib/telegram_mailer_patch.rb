require_dependency 'mailer'

module TelegramMailerPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :deliver_issue_add, :telegram
    end
  end
  
  module InstanceMethods
    # Adds a rates tab to the user administration page
    def deliver_issue_add_with_telegram(issue)
      Rails.logger.info("[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}")
      deliver_issue_add_with_telegram(issue)
    end
    
  end
end

Mailer.send(:include, RateUsersHelperPatch)
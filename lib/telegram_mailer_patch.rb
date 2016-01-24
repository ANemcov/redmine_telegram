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
    
  end
  
  module InstanceMethods
    # Adds a rates tab to the user administration page
    def issue_add_with_telegram(issue, to_users, cc_users)
      Rails.logger.info("[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}")
      issue_add_without_telegram(issue, to_users, cc_users)
    end
    
  end
end

Mailer.send(:include, TelegramMailerPatch)
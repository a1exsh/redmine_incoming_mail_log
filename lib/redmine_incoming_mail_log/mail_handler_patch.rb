module RedmineIncomingMailLog
  module MailHandlerPatch
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        include InstanceMethods
      end
    end

    module ClassMethods
      def self.extended(base)
        base.class_eval do
          class << self
            alias_method_chain :receive, :incoming_mail_log
          end
        end
      end
      
      def receive_with_incoming_mail_log(email, options)
        self.send(:class_variable_set, :@@incoming_mail, email)
        receive_without_incoming_mail_log(email, options)
      end
    end

    module InstanceMethods
      def self.included(base)
        base.class_eval do
          alias_method_chain :receive, :incoming_mail_log
        end
      end

      def receive_with_incoming_mail_log(email)
        receive_without_incoming_mail_log(email).tap do |received|
          raw_email = self.class.send(:class_variable_get, :@@incoming_mail)
          IncomingMail.create(:subject => email.subject,
                              :content => raw_email)
        end
      end
    end
  end
end

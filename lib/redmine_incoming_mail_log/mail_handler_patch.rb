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
        self.send(:class_variable_set, :@@incoming_mail,
                  IncomingMail.create(:content => email))

        receive_without_incoming_mail_log(email, options)
      end
    end

    module InstanceMethods
      def self.included(base)
        base.class_eval do
          alias_method_chain :logger, :incoming_mail_log
          alias_method_chain :receive, :incoming_mail_log
          (%w(issue) +
           %w(issue journal message).map{|m| "#{m}_reply"}).each do |model|
            base.class_eval <<-EOF
              def receive_#{model}_with_incoming_mail_log(*args)
                receive_#{model}_without_incoming_mail_log(*args)
              rescue => e
                incoming_mail.update_attribute(:error_message, e.message)
                raise e
              end
            EOF
            alias_method_chain "receive_#{model}".to_sym, :incoming_mail_log
          end
        end
      end

      def logger_with_incoming_mail_log
        @tracing_logger ||= TracingLoggerWrapper.\
        new(logger_without_incoming_mail_log || Logger.new(nil),
            Proc.new{|level, msg| (@log_messages ||= "") << "#{level}: #{msg}\n"})
      end

      def receive_with_incoming_mail_log(email)
        receive_without_incoming_mail_log(email).tap do |received|
          if incoming_mail
            # FIXME: duplicated from MailHandler
            sender_email = email.from.to_a.first.to_s.strip

            project = get_keyword(:project)
            if project.blank? && received && received.respond_to?(:project)
              project = received.project.identifier
            end

            incoming_mail.update_attributes(:sender_email => sender_email,
                                            :subject => email.subject,
                                            :target_project => project,
                                            :handled => !!received,
                                            :log_messages => @log_messages)
          end
        end
      end

      def incoming_mail
        self.class.send(:class_variable_get, :@@incoming_mail)
      end
    end
  end
end

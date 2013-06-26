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
        begin
          self.send(:class_variable_set, :@@incoming_mail,
                    IncomingMail.create!(:content => utf8_clean(email.dup)))
        rescue => e
          logger.error "MailHandler: failed to log incoming mail: #{e.inspect}" if logger
        end

        receive_without_incoming_mail_log(email, options)
      end

      def utf8_clean(text)
        text.force_encoding('ASCII-8BIT') if text.respond_to?(:force_encoding)
        text.encode!('UTF-8', :invalid => :replace, :undef => :replace,
                     :replace => '?') if text.respond_to?(:encode!)
        text
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
              rescue UnauthorizedAction
                # lower severity (original code reports an error here)
                logger.info "MailHandler: unauthorized attempt from #{@user}"
                false
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
            Proc.new{|level, *args| (@log_messages ||= "") << "#{level.upcase}: #{args.join(' ')}\n"})
      end

      def receive_with_incoming_mail_log(email)
        receive_without_incoming_mail_log(email).tap do |received|
          if incoming_mail
            project = get_keyword(:project)
            if project.blank? && received && received.respond_to?(:project)
              project = received.project.identifier
            end

            begin
              incoming_mail.update_attributes!(:sender_email => MailHandler.utf8_clean(sender_email),
                                               :subject => MailHandler.utf8_clean(email.subject),
                                               :target_project => MailHandler.utf8_clean(project),
                                               :handled => !!received,
                                               :log_messages => MailHandler.utf8_clean(@log_messages))
            rescue => e
              logger.error "MailHandler: failed to update incoming mail log: #{e.inspect}" if logger
            end

            if !received && logger.seen_error?
              settings = Setting['plugin_redmine_incoming_mail_log']
              if settings && settings['notify_failed'] == '1'
                Mailer.failed_incoming_mail(incoming_mail, settings['notify_email']).deliver
              end
            end
          end
        end
      end

      def incoming_mail
        self.class.send(:class_variable_get, :@@incoming_mail) if self.class.class_variable_defined?(:@@incoming_mail)
      end
    end
  end
end

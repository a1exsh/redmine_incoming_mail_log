module RedmineIncomingMailLog
  module MailerPatch
    def self.included(base)
      base.class_eval do
        helper IncomingMailsHelper
      end
    end

    def failed_incoming_mail(incoming_mail, notify_addresses)
      @mail = incoming_mail,
      @url = incoming_mail_url(incoming_mail)
      mail :to => notify_addresses,
        :subject => l(:mail_subject_failed_incoming_mail)
    end

    def unhandled_mail_report(mails, notify_addresses)
      @mails = mails
      mail :to => notify_addresses,
        :subject => l(:mail_subject_unhandled_mail_report)
    end
  end
end

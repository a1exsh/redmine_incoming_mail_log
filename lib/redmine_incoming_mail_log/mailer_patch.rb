module RedmineIncomingMailLog
  module MailerPatch
    def self.included(base)
      base.class_eval do
        helper IncomingMailsHelper
      end
    end

    def failed_incoming_mail(incoming_mail, notify_addresses)
      recipients notify_addresses
      subject l(:mail_subject_failed_incoming_mail)
      body :mail => incoming_mail,
        :url => incoming_mail_url(incoming_mail)
      render_multipart('failed_incoming_mail', body)
    end
  end
end

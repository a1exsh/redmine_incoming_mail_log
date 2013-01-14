class IncomingMail < ActiveRecord::Base
  unloadable

  scope :for_project, lambda { |project| where(:target_project => project) }
  scope :sender_like, lambda { |sender| where(["sender_email ILIKE ?", "%#{sender}%"]) }
  scope :subject_like, lambda { |subject| where(["subject ILIKE ?", "%#{subject}%"]) }
  scope :unhandled, where(:handled => false)
  scope :received_on, lambda { |date| where(["created_on::date = ?", date]) }
  default_scope order("created_on DESC")

  def self.report!
    settings = Setting['plugin_redmine_incoming_mail_log']
    Mailer.unhandled_mail_report(reorder("target_project, created_on DESC"), settings['notify_email']).deliver
  end

  def project
    @project ||= Project.visible.find_by_identifier(target_project)
  end

  def target_project=(project_identifier)
    @project = nil
    super project_identifier
  end

  def sender
    @sender ||= User.find_by_mail(sender_email)
  end

  def sender_email=(email)
    @sender = nil
    super email
  end

  def reload(*args)
    @project = nil
    @sender = nil
    super *args
  end

  def display_subject
    subject.present? ? subject : "(no subject)"
  end
end

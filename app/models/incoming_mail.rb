class IncomingMail < ActiveRecord::Base
  unloadable

  def project
    @project ||= Project.visible.find_by_identifier(target_project)
  end

  def target_project=(identifier)
    @project = nil
    super identifier
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

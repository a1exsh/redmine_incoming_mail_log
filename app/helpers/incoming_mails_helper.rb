module IncomingMailsHelper
  def link_to_or_project_name(mail)
    if mail.project
      link_to_project mail.project
    else
      h mail.target_project
    end
  end

  def link_to_or_sender_email(mail)
    if mail.sender
      link_to_user mail.sender
    else
      h mail.sender_email
    end
  end
end

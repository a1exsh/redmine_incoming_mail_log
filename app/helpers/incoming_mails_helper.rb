module IncomingMailsHelper
  def link_to_or_project_name(mail)
    if mail.project
      link_to_project mail.project
    else
      h mail.target_project
    end
  end
end

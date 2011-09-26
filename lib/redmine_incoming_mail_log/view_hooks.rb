module RedmineIncomingMailLog
  class ViewHooks < Redmine::Hook::ViewListener
    render_on :view_layouts_base_html_head,
      :partial => 'hooks/incoming_mail_log_stylesheet'
  end
end

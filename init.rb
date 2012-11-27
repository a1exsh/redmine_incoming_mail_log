require 'redmine'

Redmine::Plugin.register :redmine_incoming_mail_log do
  name 'Redmine Incoming Mail Log plugin'
  author 'Alex Shulgin <ash@commandprompt.com>'
  description 'A plugin to record incoming mails and statuses of handling them.'
  version '0.2.0'
  url 'http://github.com/commandprompt/redmine_incoming_mail_log'
  #  author_url 'http://example.com/about'

  menu :admin_menu, :incoming_mails,
    { :controller => 'incoming_mails', :action => 'index' },
    :caption => :label_incoming_mail_plural,
    :html => { :class => 'incoming_mails' }

  settings :default => {},
    :partial => 'settings/redmine_incoming_mail_log_settings'
end

prepare_block = Proc.new do
  MailHandler.send(:include, RedmineIncomingMailLog::MailHandlerPatch)
  Mailer.send(:include, RedmineIncomingMailLog::MailerPatch)
end

if Rails.env.development?
  ActionDispatch::Reloader.to_prepare { prepare_block.call }
else
  prepare_block.call
end

require_dependency 'redmine_incoming_mail_log/view_hooks'

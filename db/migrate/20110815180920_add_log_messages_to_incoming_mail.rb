class AddLogMessagesToIncomingMail < ActiveRecord::Migration
  def self.up
    add_column :incoming_mails, :log_messages, :text
  end

  def self.down
    remove_column :incoming_mails, :log_messages
  end
end

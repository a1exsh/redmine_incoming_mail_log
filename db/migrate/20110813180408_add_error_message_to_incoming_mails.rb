class AddErrorMessageToIncomingMails < ActiveRecord::Migration
  def self.up
    add_column :incoming_mails, :error_message, :string
  end

  def self.down
    remove_column :incoming_mails, :error_message
  end
end

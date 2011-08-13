class AddSenderEmailToIncomingMails < ActiveRecord::Migration
  def self.up
    add_column :incoming_mails, :sender_email, :string
  end

  def self.down
    remove_column :incoming_mails, :sender_email
  end
end

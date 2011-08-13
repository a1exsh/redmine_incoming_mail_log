class AddHandledToIncomingMail < ActiveRecord::Migration
  def self.up
    add_column :incoming_mails, :handled, :boolean, :default => false
  end

  def self.down
    remove_column :incoming_mails, :handled
  end
end

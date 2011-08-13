class AddTargetProjectToIncomingMail < ActiveRecord::Migration
  def self.up
    add_column :incoming_mails, :target_project, :string
  end

  def self.down
    remove_column :incoming_mails, :target_project
  end
end

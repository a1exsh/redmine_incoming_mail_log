class CreateIncomingMails < ActiveRecord::Migration
  def self.up
    create_table :incoming_mails do |t|
      t.column :subject, :string
      t.column :content, :text
      t.column :created_on, :timestamp
    end
  end

  def self.down
    drop_table :incoming_mails
  end
end

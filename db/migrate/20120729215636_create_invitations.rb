class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :email
      t.string :existing_user
      t.string :category
      t.string :verify_email_token
      t.datetime :verify_email_sent_at
      t.string :requestor_email
      t.string :ip_address
      t.integer :request_count, :default => 1
      t.string :status, :default => 'invited'

      t.timestamps
    end
  end
end

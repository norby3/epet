class AddColumnsToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :invitee_email, :string
    add_column :invitations, :invitee_upid, :string
    add_column :invitations, :invitee_status, :string
    add_column :invitations, :invitor_email, :string
    add_column :invitations, :invitor_upid, :string
    add_column :invitations, :invitor_status, :string

    add_column :invitations, :accept_count, :integer
  end
end

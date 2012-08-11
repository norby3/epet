class CreatePersonConnections < ActiveRecord::Migration
  def change
    create_table :person_connections do |t|
      t.integer :person_a_id
      t.integer :person_b_id
      t.string :category
      t.integer :invitation_id
      t.string :status, :default => 'active'

      t.timestamps
    end
  end
end

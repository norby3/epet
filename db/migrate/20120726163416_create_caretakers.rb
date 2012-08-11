class CreateCaretakers < ActiveRecord::Migration
  def change
    create_table :caretakers do |t|
      t.integer :pet_id
      t.integer :person_id
      t.integer :organization_id
      t.string :primary_role
      t.string :secondary_role
      t.string :started_at
      t.string :ended_at
      t.string :status, :default => 'active'

      t.timestamps
    end
  end
end

class CreateCaretakers < ActiveRecord::Migration
  def change
    create_table :caretakers do |t|
      t.string :pet_id
      t.string :person_id
      t.string :organization_id
      t.string :primary_role
      t.string :secondary_role
      t.string :started_at
      t.string :ended_at
      t.string :status, :default => 'active'

      t.timestamps
    end
  end
end

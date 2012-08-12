class CreatePets < ActiveRecord::Migration
  def change
    create_table :pets do |t|
      t.string :name
      t.string :gender
      t.string :breed
      t.date :birthdate
      t.string :weight
      #t.references :person
      t.string :status, :default => 'active'

      t.timestamps
    end
    #add_index :pets, :person_id
  end
end

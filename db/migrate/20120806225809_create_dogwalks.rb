class CreateDogwalks < ActiveRecord::Migration
  def change
    create_table :dogwalks do |t|
      t.references :pet
      t.references :person
      t.string :pee
      t.string :poo
      t.string :water
      t.string :treat
      t.string :food
      t.string :comments
      t.string :start_as_millis
      t.string :stop_as_millis
      t.timestamp :start
      t.timestamp :stop
      t.string :time_elapsed
      t.string :timezone
      t.string :status, :default => 'active'
      t.timestamps
    end
    add_index :dogwalks, :pet_id
    add_index :dogwalks, :person_id
  end
end

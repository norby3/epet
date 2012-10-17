class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :person_id
      t.string :name
      t.string :cordova
      t.string :platform
      t.string :uuid
      t.string :version

      t.timestamps
    end
  end
end

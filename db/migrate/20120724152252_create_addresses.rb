class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :line1
      t.string :line2
      t.string :line3
      t.string :line4
      t.string :locality
      t.string :region
      t.string :postcode
      t.string :country
      t.string :description
      t.string :updated_by
      t.date :expired_at
      t.integer :addressable_id
      t.string :addressable_type
      t.string :status

      t.timestamps
    end
  end
end

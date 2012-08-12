class CreatePetphotos < ActiveRecord::Migration
  def change
    create_table :petphotos do |t|
        t.integer :pet_id
        t.integer :dogwalk_id
      t.string :image
      t.string :address
      t.float :latitude
      t.float :longitude
      t.float :altitude
      t.string :description
      t.string :updated_by
      t.date :expired_at
      t.string :status, :default => 'active'
      t.string :device_make
      t.string :device_model
      t.string :exposure_time
      t.string :f_number
      t.string :lens_aperture
      t.string :focal_length
      t.string :flash
      t.string :image_created_at

      t.timestamps
    end
    add_index :petphotos, :pet_id
    add_index :petphotos, :dogwalk_id
  end
end

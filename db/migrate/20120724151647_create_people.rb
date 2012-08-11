class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :mobile_phone
      t.string :image
      t.string :email2
      t.string :email3
      t.string :phone2
      t.string :phone3
      t.string :timezone
      t.string :country
      t.string :personas
      t.string :status, :default => 'active'
      t.string :updated_by

      t.timestamps
    end
  end
end

class CreateHops < ActiveRecord::Migration
  def change
    create_table :hops do |t|
      t.string :upid
      t.string :email
      t.string :name
      t.string :cordova
      t.string :platform
      t.string :uuid
      t.string :version
      t.string :page
      t.string :prev_page
      t.string :ip
      t.string :net_connection
      t.string :network
      t.string :timestamp

      t.timestamps
    end
  end
end

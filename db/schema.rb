# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120914013046) do

  create_table "addresses", :force => true do |t|
    t.string   "line1"
    t.string   "line2"
    t.string   "line3"
    t.string   "line4"
    t.string   "locality"
    t.string   "region"
    t.string   "postcode"
    t.string   "country"
    t.string   "description"
    t.string   "updated_by"
    t.date     "expired_at"
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.string   "status"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "caretakers", :force => true do |t|
    t.integer  "pet_id"
    t.integer  "person_id"
    t.integer  "organization_id"
    t.string   "primary_role"
    t.string   "secondary_role"
    t.string   "started_at"
    t.string   "ended_at"
    t.string   "status",          :default => "active"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "devices", :force => true do |t|
    t.integer  "person_id"
    t.string   "name"
    t.string   "cordova"
    t.string   "platform"
    t.string   "uuid"
    t.string   "version"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dogwalks", :force => true do |t|
    t.integer  "pet_id"
    t.integer  "person_id"
    t.string   "pee"
    t.string   "poo"
    t.string   "water"
    t.string   "treat"
    t.string   "food"
    t.string   "comments"
    t.string   "start_as_millis"
    t.string   "stop_as_millis"
    t.datetime "start"
    t.datetime "stop"
    t.string   "time_elapsed"
    t.string   "timezone"
    t.string   "status",          :default => "active"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "dogwalks", ["person_id"], :name => "index_dogwalks_on_person_id"
  add_index "dogwalks", ["pet_id"], :name => "index_dogwalks_on_pet_id"

  create_table "hops", :force => true do |t|
    t.string   "upid"
    t.string   "email"
    t.string   "name"
    t.string   "cordova"
    t.string   "platform"
    t.string   "uuid"
    t.string   "version"
    t.string   "page"
    t.string   "prev_page"
    t.string   "ip"
    t.string   "net_connection"
    t.string   "network"
    t.string   "timestamp"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "invitations", :force => true do |t|
    t.string   "email"
    t.string   "existing_user"
    t.string   "category"
    t.string   "verify_email_token"
    t.datetime "verify_email_sent_at"
    t.string   "requestor_email"
    t.string   "ip_address"
    t.integer  "request_count",        :default => 1
    t.string   "status",               :default => "invited"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  create_table "people", :force => true do |t|
    t.integer  "user_id"
    t.string   "upid"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "mobile_phone"
    t.string   "image"
    t.string   "email2"
    t.string   "email3"
    t.string   "phone2"
    t.string   "phone3"
    t.string   "timezone"
    t.string   "country"
    t.string   "personas"
    t.string   "num_pets_owned"
    t.string   "comments"
    t.string   "status",         :default => "active"
    t.string   "updated_by"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "person_connections", :force => true do |t|
    t.integer  "person_a_id"
    t.integer  "person_b_id"
    t.string   "category"
    t.integer  "invitation_id"
    t.string   "status",        :default => "active"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "petphotos", :force => true do |t|
    t.integer  "pet_id"
    t.integer  "dogwalk_id"
    t.string   "image"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.float    "altitude"
    t.string   "description"
    t.string   "updated_by"
    t.date     "expired_at"
    t.string   "status",           :default => "active"
    t.string   "device_make"
    t.string   "device_model"
    t.string   "exposure_time"
    t.string   "f_number"
    t.string   "lens_aperture"
    t.string   "focal_length"
    t.string   "flash"
    t.string   "image_created_at"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "petphotos", ["dogwalk_id"], :name => "index_petphotos_on_dogwalk_id"
  add_index "petphotos", ["pet_id"], :name => "index_petphotos_on_pet_id"

  create_table "pets", :force => true do |t|
    t.string   "name"
    t.string   "gender"
    t.string   "breed"
    t.date     "birthdate"
    t.string   "weight"
    t.string   "status",     :default => "active"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "status",                 :default => "active"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

end

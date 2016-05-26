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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160526183811) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "check_ins", force: :cascade do |t|
    t.integer  "deliverer_id"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.datetime "timestamp"
    t.integer  "section_id"
    t.boolean  "is_holiday",   default: false
  end

  add_index "check_ins", ["deliverer_id", "timestamp"], name: "index_check_ins_on_deliverer_id_and_timestamp", using: :btree
  add_index "check_ins", ["deliverer_id"], name: "index_check_ins_on_deliverer_id", using: :btree
  add_index "check_ins", ["section_id", "timestamp"], name: "index_check_ins_on_section_id_and_timestamp", using: :btree
  add_index "check_ins", ["section_id"], name: "index_check_ins_on_section_id", using: :btree
  add_index "check_ins", ["timestamp"], name: "index_check_ins_on_timestamp", using: :btree

  create_table "deliverers", force: :cascade do |t|
    t.string "plate_number"
  end

  create_table "districts", force: :cascade do |t|
    t.string "name"
  end

  create_table "neighbourhoods", force: :cascade do |t|
    t.string  "name"
    t.integer "district_id"
  end

  create_table "section_configurations", force: :cascade do |t|
    t.integer "tariff_id"
    t.integer "schedule_id"
    t.integer "configuration_type_id"
    t.string  "color_desc"
    t.string  "color_desc_pda"
    t.string  "configuration_code"
    t.boolean "active"
    t.string  "tariff_code"
    t.string  "schedule_code"
    t.string  "configuration_type_code"
    t.string  "description"
    t.string  "tarrif_description_short"
    t.string  "schedule_description_short"
    t.boolean "include_holidays"
    t.boolean "only_parking"
    t.integer "fraction_type"
    t.integer "fraction_price"
    t.decimal "max_time"
    t.decimal "price_per_hour"
    t.decimal "price_per_minute"
    t.decimal "price_per_second"
  end

  create_table "sections", force: :cascade do |t|
    t.decimal "latitude"
    t.decimal "longitude"
    t.integer "dum_zone_id"
    t.string  "section_name"
    t.integer "street_id"
    t.integer "street_no"
    t.integer "section_type_id"
    t.integer "authorized_spaces"
    t.integer "unavailable_spaces"
    t.integer "available_spaces"
    t.integer "section_configuration_id"
    t.integer "district_id"
    t.integer "neighbourhood_id"
    t.integer "regulatory_zone_id"
    t.boolean "geocoded",                 default: false
  end

  create_table "streets", force: :cascade do |t|
    t.string "street_type"
    t.string "official_name"
    t.string "short_name"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end

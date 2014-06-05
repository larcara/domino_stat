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

ActiveRecord::Schema.define(version: 20140603065050) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "domino_servers", force: true do |t|
    t.string   "name"
    t.string   "ip"
    t.string   "ldap_port"
    t.boolean  "ldap_ssl"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "names_entries", force: true do |t|
    t.integer  "domino_server_id"
    t.string   "cn"
    t.string   "lastname"
    t.string   "firstname"
    t.string   "mailserver"
    t.string   "email"
    t.string   "level0"
    t.string   "level1"
    t.string   "level2"
    t.string   "level3"
    t.string   "level4"
    t.string   "uid"
    t.string   "displayname"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: true do |t|
    t.string   "var",         null: false
    t.text     "value"
    t.integer  "target_id",   null: false
    t.string   "target_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true, using: :btree

end

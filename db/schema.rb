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

ActiveRecord::Schema.define(version: 20140618104208) do

  create_table "domino_connections", force: true do |t|
    t.integer  "domino_server_id"
    t.datetime "date"
    t.string   "connection_type"
    t.string   "ip"
    t.string   "user"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domino_locks", force: true do |t|
    t.integer  "domino_server_id"
    t.datetime "date"
    t.string   "database_name"
    t.string   "lock_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domino_messages", force: true do |t|
    t.datetime "date"
    t.integer  "domino_server_id"
    t.string   "messageid"
    t.string   "notes_message_id"
    t.string   "mail_from"
    t.string   "mail_to"
    t.integer  "size"
    t.string   "smtp_from"
    t.string   "mail_relay"
    t.string   "forward_by_rule"
    t.string   "message_type"
    t.string   "subject"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message_subtype"
    t.string   "domain_from"
    t.string   "domain_to"
  end

  create_table "domino_servers", force: true do |t|
    t.string   "name"
    t.string   "ip"
    t.string   "ldap_port"
    t.boolean  "ldap_ssl"
    t.string   "ldap_username"
    t.string   "ldap_password"
    t.string   "ldap_treebase"
    t.string   "ldap_hostname"
    t.string   "ldap_filter"
    t.string   "ssh_user"
    t.string   "ssh_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tail_status"
    t.boolean  "enabled_tail"
    t.boolean  "enabled_auth"
  end

  create_table "names_entries", force: true do |t|
    t.integer  "domino_server_id"
    t.string   "cn"
    t.string   "lastname"
    t.string   "firstname"
    t.string   "email"
    t.string   "mailserver"
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

  create_table "notifications", force: true do |t|
    t.string   "notification_type"
    t.date     "date"
    t.string   "label"
    t.string   "description"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "level"
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

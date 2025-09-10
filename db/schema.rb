# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_10_172505) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "channel_permissions", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "target_type", null: false
    t.string "target_id", null: false
    t.string "permission_type", null: false
    t.boolean "allowed", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id", "permission_type"], name: "idx_channel_perms_type"
    t.index ["channel_id", "target_type", "target_id"], name: "idx_channel_perms_target"
    t.index ["channel_id"], name: "index_channel_permissions_on_channel_id"
  end

  create_table "channels", force: :cascade do |t|
    t.bigint "server_id", null: false
    t.string "name", null: false
    t.string "channel_type", default: "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.json "settings", default: {}
    t.index ["server_id"], name: "index_channels_on_server_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "server_id", null: false
    t.string "user_auth0_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_id", "user_auth0_id"], name: "index_memberships_on_server_id_and_user_auth0_id", unique: true
    t.index ["server_id"], name: "index_memberships_on_server_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "user_auth0_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_messages_on_channel_id"
  end

  create_table "role_assignments", force: :cascade do |t|
    t.bigint "membership_id", null: false
    t.bigint "server_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id", "server_role_id"], name: "index_role_assignments_on_membership_id_and_server_role_id", unique: true
    t.index ["membership_id"], name: "index_role_assignments_on_membership_id"
    t.index ["server_role_id"], name: "index_role_assignments_on_server_role_id"
  end

  create_table "server_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "server_roles", force: :cascade do |t|
    t.bigint "server_id", null: false
    t.string "name", null: false
    t.string "color", default: "#99AAB5"
    t.text "description"
    t.integer "position", default: 0
    t.boolean "mentionable", default: true
    t.boolean "hoist", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "permission_level", default: 10, null: false
    t.index ["server_id", "name"], name: "index_server_roles_on_server_id_and_name", unique: true
    t.index ["server_id", "position"], name: "index_server_roles_on_server_id_and_position"
    t.index ["server_id"], name: "index_server_roles_on_server_id"
  end

  create_table "servers", force: :cascade do |t|
    t.string "name", null: false, comment: "サーバー名"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invite_code"
    t.index ["invite_code"], name: "index_servers_on_invite_code"
  end

  create_table "tests", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "auth0_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth0_id"], name: "index_users_on_auth0_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "channel_permissions", "channels"
  add_foreign_key "channels", "servers"
  add_foreign_key "memberships", "servers"
  add_foreign_key "messages", "channels"
  add_foreign_key "role_assignments", "memberships"
  add_foreign_key "role_assignments", "server_roles"
  add_foreign_key "server_roles", "servers"
end

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

ActiveRecord::Schema[8.0].define(version: 2025_09_12_124001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "attachments", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "filename", null: false
    t.string "url"
    t.integer "byte_size"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_attachments_on_channel_id"
  end

  create_table "budget_entries", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.integer "kind", default: 0, null: false
    t.string "title", null: false
    t.integer "amount", default: 0, null: false
    t.date "occurred_on"
    t.string "created_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_budget_entries_on_channel_id"
  end

  create_table "channel_files", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "uploaded_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_channel_files_on_channel_id"
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

  create_table "diary_entries", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.string "created_by", null: false
    t.date "entry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_diary_entries_on_channel_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "title", null: false
    t.text "description"
    t.datetime "start_at", null: false
    t.datetime "end_at"
    t.string "user_auth0_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_events_on_channel_id"
  end

  create_table "feature_contents", force: :cascade do |t|
    t.bigint "feature_id", null: false
    t.string "user_auth0_id"
    t.string "title"
    t.text "content"
    t.string "content_type"
    t.bigint "parent_content_id"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_id"], name: "index_feature_contents_on_feature_id"
    t.index ["parent_content_id"], name: "index_feature_contents_on_parent_content_id"
  end

  create_table "features", force: :cascade do |t|
    t.bigint "server_id", null: false
    t.string "name"
    t.string "feature_type"
    t.string "icon"
    t.integer "position"
    t.text "settings"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_id"], name: "index_features_on_server_id"
  end

  create_table "forum_posts", force: :cascade do |t|
    t.bigint "forum_topic_id", null: false
    t.text "content", null: false
    t.string "user_auth0_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "forum_thread_id", null: false
    t.string "created_by", null: false
    t.index ["forum_thread_id"], name: "index_forum_posts_on_forum_thread_id"
    t.index ["forum_topic_id"], name: "index_forum_posts_on_forum_topic_id"
  end

  create_table "forum_threads", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "title", null: false
    t.string "created_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_forum_threads_on_channel_id"
  end

  create_table "forum_topics", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "title", null: false
    t.text "body"
    t.string "user_auth0_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_forum_topics_on_channel_id"
  end

  create_table "inventory_items", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "name", null: false
    t.integer "quantity", default: 0, null: false
    t.string "location"
    t.string "updated_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_inventory_items_on_channel_id"
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

  create_table "photos", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "caption"
    t.string "uploaded_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_photos_on_channel_id"
  end

  create_table "server_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "servers", force: :cascade do |t|
    t.string "name", null: false, comment: "サーバー名"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invite_code"
    t.string "owner_auth0_id"
    t.text "description"
    t.boolean "is_public"
    t.text "settings"
    t.string "api_token"
    t.index ["api_token"], name: "index_servers_on_api_token", unique: true
    t.index ["invite_code"], name: "index_servers_on_invite_code"
  end

  create_table "survey_options", force: :cascade do |t|
    t.bigint "survey_id", null: false
    t.string "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_survey_options_on_survey_id"
  end

  create_table "survey_votes", force: :cascade do |t|
    t.bigint "survey_id", null: false
    t.bigint "survey_option_id", null: false
    t.string "voter", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id", "voter"], name: "index_survey_votes_on_survey_id_and_voter", unique: true
    t.index ["survey_id"], name: "index_survey_votes_on_survey_id"
    t.index ["survey_option_id"], name: "index_survey_votes_on_survey_option_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "question", null: false
    t.boolean "multiple", default: false, null: false
    t.datetime "expires_at"
    t.string "created_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_surveys_on_channel_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.date "due_date"
    t.string "assignee"
    t.string "created_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_tasks_on_channel_id"
  end

  create_table "tests", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_profiles", force: :cascade do |t|
    t.string "auth0_id"
    t.string "display_name"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth0_id"], name: "index_user_profiles_on_auth0_id", unique: true
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

  create_table "whiteboards", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.jsonb "operations", default: {}, null: false
    t.string "updated_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_whiteboards_on_channel_id"
  end

  create_table "wiki_pages", force: :cascade do |t|
    t.bigint "channel_id", null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.string "user_auth0_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id", "slug"], name: "index_wiki_pages_on_channel_id_and_slug", unique: true
    t.index ["channel_id"], name: "index_wiki_pages_on_channel_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attachments", "channels"
  add_foreign_key "budget_entries", "channels"
  add_foreign_key "channel_files", "channels"
  add_foreign_key "channels", "servers"
  add_foreign_key "diary_entries", "channels"
  add_foreign_key "events", "channels"
  add_foreign_key "feature_contents", "feature_contents", column: "parent_content_id"
  add_foreign_key "feature_contents", "features"
  add_foreign_key "features", "servers"
  add_foreign_key "forum_posts", "forum_threads"
  add_foreign_key "forum_posts", "forum_topics"
  add_foreign_key "forum_threads", "channels"
  add_foreign_key "forum_topics", "channels"
  add_foreign_key "inventory_items", "channels"
  add_foreign_key "memberships", "servers"
  add_foreign_key "messages", "channels"
  add_foreign_key "photos", "channels"
  add_foreign_key "survey_options", "surveys"
  add_foreign_key "survey_votes", "survey_options"
  add_foreign_key "survey_votes", "surveys"
  add_foreign_key "surveys", "channels"
  add_foreign_key "tasks", "channels"
  add_foreign_key "whiteboards", "channels"
  add_foreign_key "wiki_pages", "channels"
end

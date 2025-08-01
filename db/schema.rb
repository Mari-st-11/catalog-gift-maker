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

ActiveRecord::Schema[7.2].define(version: 2025_07_31_083152) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "gift_items", force: :cascade do |t|
    t.text "url"
    t.string "name"
    t.text "description"
    t.string "image"
    t.integer "status"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "gift_list_uuid"
    t.index ["gift_list_uuid"], name: "index_gift_items_on_gift_list_uuid"
    t.index ["user_id"], name: "index_gift_items_on_user_id"
  end

  create_table "gift_lists", primary_key: "uuid", id: :uuid, default: nil, force: :cascade do |t|
    t.string "recipient_name", null: false
    t.string "purpose"
    t.integer "cover_image"
    t.string "public_name"
    t.boolean "is_public", default: true
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content"
    t.index ["user_id"], name: "index_gift_lists_on_user_id"
    t.index ["uuid"], name: "index_gift_lists_on_uuid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "gift_items", "gift_lists", column: "gift_list_uuid", primary_key: "uuid"
  add_foreign_key "gift_items", "users"
  add_foreign_key "gift_lists", "users"
end

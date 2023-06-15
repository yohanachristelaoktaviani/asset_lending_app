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

ActiveRecord::Schema.define(version: 2023_06_12_102753) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "asset_loan_items", force: :cascade do |t|
    t.bigint "asset_loan_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "loan_status", limit: 50
    t.string "evidence", limit: 100
    t.bigint "admin_id"
    t.index ["asset_loan_id"], name: "index_asset_loan_items_on_asset_loan_id"
    t.index ["item_id"], name: "index_asset_loan_items_on_item_id"
  end

  create_table "asset_loans", force: :cascade do |t|
    t.string "code", limit: 45
    t.datetime "loan_item_datetime"
    t.datetime "return_estimation_datetime"
    t.string "necessary", limit: 200
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "code_loan", unique: true
    t.index ["code"], name: "index_asset_loans_on_code", unique: true
  end

  create_table "asset_return_items", force: :cascade do |t|
    t.string "return_status", limit: 50
    t.bigint "asset_return_id", null: false
    t.bigint "item_id", null: false
    t.string "actual_item_condition", limit: 50
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "admin_id"
    t.string "status", limit: 50
    t.index ["asset_return_id"], name: "index_asset_return_items_on_asset_return_id"
    t.index ["item_id"], name: "index_asset_return_items_on_item_id"
  end

  create_table "asset_returns", force: :cascade do |t|
    t.string "code", limit: 45
    t.datetime "actual_return_datetime"
    t.bigint "asset_loan_id", null: false
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["asset_loan_id"], name: "index_asset_returns_on_asset_loan_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "code_name", limit: 50
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code_name"], name: "code_dep", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.string "code", limit: 45, null: false
    t.string "name", limit: 100
    t.string "merk", limit: 50
    t.string "condition", limit: 50
    t.string "vendor_name", limit: 50
    t.string "status", limit: 50
    t.string "description", limit: 300
    t.string "image", limit: 300
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "code_items", unique: true
  end

  create_table "positions", force: :cascade do |t|
    t.string "code_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code_name"], name: "code_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "code", limit: 45, null: false
    t.string "name", limit: 100
    t.integer "department_id"
    t.integer "position_id"
    t.string "role", limit: 50
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "code", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "asset_loan_items", "asset_loans"
  add_foreign_key "asset_loan_items", "items"
  add_foreign_key "asset_loan_items", "users", column: "admin_id", name: "fk_rails_admin_id"
  add_foreign_key "asset_loans", "users"
  add_foreign_key "asset_return_items", "asset_returns"
  add_foreign_key "asset_return_items", "items"
  add_foreign_key "asset_return_items", "users", column: "admin_id", name: "fk_rails_admin"
  add_foreign_key "asset_returns", "asset_loans"
  add_foreign_key "asset_returns", "users"
  add_foreign_key "users", "departments", name: "department_id"
  add_foreign_key "users", "positions", name: "position_id"
end

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

ActiveRecord::Schema.define(version: 2023_06_09_012608) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "code", limit: 45
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

  add_foreign_key "users", "departments", name: "department_id"
  add_foreign_key "users", "positions", name: "position_id"
end

class AddForeignKeyAdminToItem < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key "items", "users", column: "admin_id"
  end
end

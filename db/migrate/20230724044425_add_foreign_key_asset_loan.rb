class AddForeignKeyAssetLoan < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :asset_loans, :users, column: :admin_id, primary_key: "id"
  end
end

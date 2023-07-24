class AddForeignKeyAssetReturnItem < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :asset_returns, :users, column: :admin_id, primary_key: "id"
  end
end

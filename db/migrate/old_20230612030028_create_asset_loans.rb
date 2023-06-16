class CreateAssetLoans < ActiveRecord::Migration[6.1]
  def change
    create_table :asset_loans do |t|
      t.string   :code, limit: 45, unique: true
      t.datetime :loan_item_datetime
      t.datetime :return_estimation_datetime
      t.string   :necessary, limit: 200
      t.integer  :user_id

      t.timestamps
    end
    add_foreign_key :asset_loans, :users, column: :user_id, primary_key: "id"

    add_index :asset_loans, :code,                 unique: true
  end
end

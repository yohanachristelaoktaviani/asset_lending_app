class CreateAssetReturns < ActiveRecord::Migration[6.1]
  def change
    create_table :asset_returns do |t|
      t.string :code, limit: 45, unique: true
      t.datetime :actual_return_datetime
      t.references :asset_loan, null: false, foreign_key: {to_table: :asset_loans}
      t.integer  :user_id


      t.timestamps
    end
    add_foreign_key :asset_returns, :users, column: :user_id, primary_key: "id"

    add_index :asset_loans, :code,                 unique: true
  end
end

class CreateAssetLoanItems < ActiveRecord::Migration[6.1]
  def change
    create_table :asset_loan_items do |t|
      t.references :asset_loan, null: false, foreign_key: {to_table: :asset_loans}
      t.references :item, null: false, foreign_key: {to_table: :items}
      t.string   :loan_status, limit: 50
      t.string   :evidence, limit: 100
      t.integer  :admin_id

      t.timestamps
    end


  end
end

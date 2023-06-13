class CreateAssetReturnItems < ActiveRecord::Migration[6.1]
  def change
    create_table :asset_return_items do |t|
      t.string :return_status, limit: 50
      t.references :asset_return, null: false, foreign_key: {to_table: :asset_returns}
      t.references :item, null: false, foreign_key: {to_table: :items}
      t.string  :actual_item_condition, limit: 50

      t.timestamps
    end


  end
end

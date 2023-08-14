class AddNewColumnToItem < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :location, :string, limit: 50
    add_column :items, :serial_number, :string, limit: 50
    add_column :items, :purchase_date, :datetime
    add_column :items, :admin_id, :integer
  end
end

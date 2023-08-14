class AddColumnSelectedToItem < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :selected_item, :boolean
  end
end

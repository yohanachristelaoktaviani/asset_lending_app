class ChangePositionIdtoPosition < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :position_id, :position
  end
end

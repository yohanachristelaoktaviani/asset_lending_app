class ChangePositionUser < ActiveRecord::Migration[6.1]
  def change
    change_column(:users, :position_id, :string, limit: 150)
  end
end

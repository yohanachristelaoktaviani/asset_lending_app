class RemoveForeignKeyPositionUser < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :users, name: "fk_rails_2d26d9377b"
  end
end

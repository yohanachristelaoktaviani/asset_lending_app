class CreatePositions < ActiveRecord::Migration[6.1]
  def change
    create_table :positions do |t|
      t.string :code_name, limit: 50, unique: true

      t.timestamps
    end
  end
end

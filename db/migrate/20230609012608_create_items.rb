class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :code, limit: 45, unique: true, null: false
      t.string :name, limit: 100
      t.string :merk, limit: 50
      t.string :condition, limit: 50
      t.string :vendor_name, limit: 50
      t.string :status, limit: 50
      t.string :description, limit: 300
      t.string :image, limit: 300

      t.timestamps
    end

    add_index :items, :code,                 unique: true
  end
end

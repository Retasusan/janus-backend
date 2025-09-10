class CreateServerRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :server_roles do |t|
      t.references :server, null: false, foreign_key: true
      t.string :name, null: false
      t.string :color, default: '#99AAB5'
      t.text :description
      t.integer :position, default: 0
      t.boolean :mentionable, default: true
      t.boolean :hoist, default: false  # ロールを別表示するか

      t.timestamps
    end

    add_index :server_roles, [:server_id, :name], unique: true
    add_index :server_roles, [:server_id, :position]
  end
end
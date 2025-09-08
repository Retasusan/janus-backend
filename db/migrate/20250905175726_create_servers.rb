class CreateServers < ActiveRecord::Migration[8.0]
  def change
    create_table :servers do |t|
      t.string :name, null: false
      t.text :description
      t.string :created_by, null: false  # Auth0のsub
      t.timestamps
    end
  end
end

class CreateEvents < ActiveRecord::Migration[8.0]
  def change
  create_table :events, if_not_exists: true do |t|
      t.references :channel, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :start_at, null: false
      t.datetime :end_at
      t.boolean :all_day, null: false, default: false
      t.string :created_by, null: false
      t.timestamps
    end
  end
end

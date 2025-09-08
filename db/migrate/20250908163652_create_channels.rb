class CreateChannels < ActiveRecord::Migration[8.0]
  def change
    create_table :channels do |t|
      t.references :server, null: false, foreign_key: true
      t.string :name, null: false
      t.string :channel_type, null: false, default: "text"
      t.timestamps
    end
  end
end

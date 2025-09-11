class CreateChannelFiles < ActiveRecord::Migration[8.0]
  def change
  create_table :channel_files, if_not_exists: true do |t|
      t.references :channel, null: false, foreign_key: true
      t.string :uploaded_by, null: false
      t.timestamps
    end
  end
end

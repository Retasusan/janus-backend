class CreateMessages < ActiveRecord::Migration[8.0]
  def change
  create_table :messages, if_not_exists: true do |t|
      t.references :channel, null: false, foreign_key: true
      t.string :user_auth0_id, null: false
      t.text :content, null: false
      t.timestamps
    end
  end
end

class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :server, null: false, foreign_key: true
      t.string :user_auth0_id, null: false
      t.string :role, null: false, default: "member"
      t.timestamps
    end

    add_index :memberships, [:server_id, :user_auth0_id], unique: true
  end
end

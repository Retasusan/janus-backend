class CreateUserProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_profiles do |t|
      t.string :auth0_id
      t.string :display_name
      t.string :avatar_url

      t.timestamps
    end
    add_index :user_profiles, :auth0_id, unique: true
  end
end

class AddApiTokenToServers < ActiveRecord::Migration[8.0]
  def change
    add_column :servers, :api_token, :string
    add_index :servers, :api_token, unique: true
  end
end

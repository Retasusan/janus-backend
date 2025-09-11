class AddInviteCodeToServers < ActiveRecord::Migration[8.0]
  def change
  add_column :servers, :invite_code, :string unless column_exists?(:servers, :invite_code)
  add_index :servers, :invite_code, if_not_exists: true
  end
end

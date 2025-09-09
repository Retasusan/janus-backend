class AddInviteCodeToServers < ActiveRecord::Migration[8.0]
  def change
    add_column :servers, :invite_code, :string
    add_index :servers, :invite_code
  end
end

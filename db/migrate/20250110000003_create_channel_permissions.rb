class CreateChannelPermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :channel_permissions do |t|
      t.references :channel, null: false, foreign_key: true
      t.string :target_type, null: false  # 'role' or 'user'
      t.string :target_id, null: false    # role name or user_auth0_id
      t.string :permission_type, null: false
      t.boolean :allowed, default: true

      t.timestamps
    end

    add_index :channel_permissions, [:channel_id, :target_type, :target_id], name: 'idx_channel_perms_target'
    add_index :channel_permissions, [:channel_id, :permission_type], name: 'idx_channel_perms_type'
  end
end
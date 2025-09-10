class AddPermissionLevelToServerRoles < ActiveRecord::Migration[8.0]
  def change
    add_column :server_roles, :permission_level, :integer, default: 10, null: false
    
    # 既存のロールにデフォルト値を設定
    reversible do |dir|
      dir.up do
        # 既存のロールの権限レベルを設定
        execute <<-SQL
          UPDATE server_roles 
          SET permission_level = CASE 
            WHEN LOWER(name) LIKE '%admin%' THEN 100
            WHEN LOWER(name) LIKE '%moderator%' OR LOWER(name) LIKE '%mod%' THEN 50
            WHEN LOWER(name) LIKE '%member%' THEN 10
            ELSE 10
          END
        SQL
      end
    end
  end
end

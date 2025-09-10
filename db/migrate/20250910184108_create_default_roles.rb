class CreateDefaultRoles < ActiveRecord::Migration[8.0]
  def change
    # 既存のサーバーに対してデフォルトロールを作成
    reversible do |dir|
      dir.up do
        Server.find_each do |server|
          create_default_roles_for_server(server)
        end
      end
    end
  end

  private

  def create_default_roles_for_server(server)
    default_roles = [
      { name: 'admin', color: '#dc2626', description: 'サーバー管理者' },
      { name: 'moderator', color: '#2563eb', description: 'モデレーター' },
      { name: 'member', color: '#059669', description: 'メンバー' },
      { name: 'readonly', color: '#9333ea', description: '読み取り専用' },
      { name: 'ob', color: '#6b7280', description: 'OB（読み取りのみ）' },
      { name: 'guest', color: '#9ca3af', description: 'ゲスト' }
    ]

    default_roles.each do |role_data|
      server.server_roles.find_or_create_by(name: role_data[:name]) do |role|
        role.color = role_data[:color]
        role.description = role_data[:description]
      end
    end
  end
end

# デフォルトロールを作成するシードファイル

# 各サーバーにデフォルトロールを作成
Server.find_each do |server|
  # デフォルトロールが存在しない場合のみ作成
  unless server.server_roles.exists?
    default_roles = [
      {
        name: 'admin',
        color: '#F04747',
        description: 'サーバーの完全な管理権限を持ちます',
        position: 100,
        permission_level: 100
      },
      {
        name: 'moderator',
        color: '#FAA61A',
        description: 'チャンネルとメッセージの管理権限を持ちます',
        position: 50,
        permission_level: 50
      },
      {
        name: 'member',
        color: '#43B581',
        description: '一般的なメンバー権限を持ちます',
        position: 10,
        permission_level: 10
      },
      {
        name: 'guest',
        color: '#99AAB5',
        description: '限定的な閲覧権限のみを持ちます',
        position: 1,
        permission_level: 1
      }
    ]

    default_roles.each do |role_data|
      server.server_roles.create!(role_data)
    end

    puts "Created default roles for server: #{server.name}"
  end
end

# 既存のメンバーシップにデフォルトロールを割り当て
Membership.includes(:role_assignments, server: :server_roles).find_each do |membership|
  # ロール割り当てがない場合、memberロールを割り当て
  if membership.role_assignments.empty?
    member_role = membership.server.server_roles.find_by(name: 'member')
    if member_role
      membership.role_assignments.create!(server_role: member_role)
      puts "Assigned member role to user: #{membership.user_auth0_id} in server: #{membership.server.name}"
    end
  end
end

puts "Seed completed!"
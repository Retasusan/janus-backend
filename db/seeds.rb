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
        position: 100
      },
      {
        name: 'moderator',
        color: '#FAA61A',
        description: 'チャンネルとメッセージの管理権限を持ちます',
        position: 50
      },
      {
        name: 'member',
        color: '#43B581',
        description: '一般的なメンバー権限を持ちます',
        position: 10
      },
      {
        name: 'guest',
        color: '#99AAB5',
        description: '限定的な閲覧権限のみを持ちます',
        position: 1
      }
    ]

    default_roles.each do |role_data|
      server.server_roles.create!(role_data)
    end

    puts "Created default roles for server: #{server.name}"
  end
end

puts "Seed completed!"
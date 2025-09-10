namespace :servers do
  desc "Add default channels to existing servers"
  task add_default_channels: :environment do
    puts "Adding default channels to existing servers..."
    
    Server.find_each do |server|
      # 権限管理チャンネルが存在しない場合のみ作成
      unless server.channels.exists?(channel_type: 'rbac')
        server.channels.create!(
          name: '権限管理',
          channel_type: 'rbac',
          description: 'サーバーの権限とロールを管理するチャンネルです'
        )
        puts "Added RBAC channel to server '#{server.name}'"
      end
      
      # 一般チャンネルが存在しない場合のみ作成
      unless server.channels.exists?(name: '一般')
        server.channels.create!(
          name: '一般',
          channel_type: 'text',
          description: '一般的な雑談用チャンネルです'
        )
        puts "Added general channel to server '#{server.name}'"
      end
    end
    
    puts "Completed adding default channels"
  end
end

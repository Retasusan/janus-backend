namespace :servers do
  desc "Set owners for existing servers"
  task set_owners: :environment do
    puts "Setting owners for existing servers..."
    
    # created_byが空のサーバーを取得
    servers_without_owner = Server.where(created_by: "")
    
    servers_without_owner.each do |server|
      # 最初のAdmin権限を持つメンバーをオーナーにする
      admin_membership = server.memberships
                              .joins(:role_assignments)
                              .joins("JOIN server_roles ON role_assignments.server_role_id = server_roles.id")
                              .where("server_roles.name ILIKE ?", "%admin%")
                              .first
      
      if admin_membership
        server.update!(created_by: admin_membership.user_auth0_id)
        puts "Set owner for server '#{server.name}' to user #{admin_membership.user_auth0_id}"
      else
        # Adminがいない場合は最初のメンバーをオーナーにする
        first_membership = server.memberships.first
        if first_membership
          server.update!(created_by: first_membership.user_auth0_id)
          puts "Set owner for server '#{server.name}' to first member #{first_membership.user_auth0_id}"
        else
          puts "Warning: Server '#{server.name}' has no members"
        end
      end
    end
    
    puts "Completed setting owners for #{servers_without_owner.count} servers"
  end
end

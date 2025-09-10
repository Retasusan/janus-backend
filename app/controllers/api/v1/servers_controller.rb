module Api
  module V1
    class ServersController < ApplicationController
      before_action :authorize_request

      # サーバー一覧（所属しているサーバーのみ）
      def index
        servers = user_servers
        render json: servers
      end

      # サーバー作成
      def create
        server = Server.new(server_params.merge(created_by: current_user_auth0_id))

        ActiveRecord::Base.transaction do
          if server.save
            # メンバーシップ作成
            membership = Membership.create!(
              server: server, 
              user_auth0_id: current_user_auth0_id, 
              role: "owner"
            )
            
            # デフォルトロールが存在しない場合は作成
            ensure_default_roles(server)
            
            # 作成者にAdminロールを自動割り当て
            admin_role = server.server_roles.find_by(name: 'admin')
            if admin_role
              membership.role_assignments.create!(server_role: admin_role)
            end
            
            # デフォルトチャンネルを作成
            create_default_channels(server)
            
            render json: server_response(server), status: :created
          else
            render json: { errors: server.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue => e
        render json: { error: "Server creation failed: #{e.message}" }, status: :unprocessable_entity
      end

      # サーバー参加
      def join
        invite_code = params[:inviteCode] || params[:invite_code]
        server = Server.find_by_invite_code(invite_code)

        unless server
          render json: { error: "Invalid invite code" }, status: :not_found
          return
        end

        # 既に参加しているかチェック
        existing_membership = server.memberships.find_by(user_auth0_id: current_user_auth0_id)
        if existing_membership
          render json: { error: "Already a member of this server" }, status: :conflict
          return
        end

        membership = server.memberships.create!(user_auth0_id: current_user_auth0_id, role: "member")
        render json: server_response(server), status: :created
      end

      # 招待コード情報取得（参加前にサーバー情報を確認）
      def invite_info
        invite_code = params[:inviteCode] || params[:invite_code]
        server = Server.find_by_invite_code(invite_code)

        unless server
          render json: { error: "Invalid invite code" }, status: :not_found
          return
        end

        render json: {
          id: server.id,
          name: server.name,
          memberCount: server.memberships.count
        }
      end

      # 招待コード生成/取得（サーバーメンバーなら誰でも）
      def invite
        server = user_servers.find(params[:id])
        
        # 招待コードがない場合は生成
        if server.invite_code.blank?
          server.regenerate_invite_code!
        end

        render json: { inviteCode: server.invite_code }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Server not found or access denied" }, status: :not_found
      end

      # 招待コード再生成（サーバーオーナーのみ）
      def regenerate_invite_code
        server = user_servers.find(params[:id])
        membership = server.memberships.find_by(user_auth0_id: current_user_auth0_id)

        unless membership&.role == "owner"
          render json: { error: "Only server owners can regenerate invite codes" }, status: :forbidden
          return
        end

        server.regenerate_invite_code!
        render json: server_response(server)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Server not found or access denied" }, status: :not_found
      end

      private

      def server_params
        params.require(:server).permit(:name)
      end

      def ensure_default_roles(server)
        # デフォルトロールを作成（存在しない場合のみ）
        default_roles = [
          { name: 'admin', permission_level: 100, color: '#DC2626', description: '管理者権限' },
          { name: 'moderator', permission_level: 50, color: '#7C3AED', description: 'モデレーター権限' },
          { name: 'member', permission_level: 10, color: '#059669', description: '一般メンバー権限' },
          { name: 'readonly', permission_level: 3, color: '#6B7280', description: '読み取り専用権限' },
          { name: 'ob', permission_level: 2, color: '#9CA3AF', description: 'OB権限' },
          { name: 'guest', permission_level: 1, color: '#D1D5DB', description: 'ゲスト権限' }
        ]

        default_roles.each do |role_data|
          server.server_roles.find_or_create_by(name: role_data[:name]) do |role|
            role.permission_level = role_data[:permission_level]
            role.color = role_data[:color]
            role.description = role_data[:description]
          end
        end
      end

      def create_default_channels(server)
        # デフォルトチャンネルを作成
        default_channels = [
          {
            name: '権限管理',
            channel_type: 'rbac',
            description: 'サーバーの権限とロールを管理するチャンネルです'
          },
          {
            name: '一般',
            channel_type: 'text',
            description: '一般的な雑談用チャンネルです'
          }
        ]

        default_channels.each do |channel_data|
          server.channels.create!(
            name: channel_data[:name],
            channel_type: channel_data[:channel_type],
            description: channel_data[:description]
          )
        end
      end

      def server_response(server)
        {
          id: server.id,
          name: server.name,
          inviteCode: server.invite_code,
          createdAt: server.created_at,
          updatedAt: server.updated_at
        }
      end
    end
  end
end
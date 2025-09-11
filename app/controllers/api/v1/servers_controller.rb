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
        server = Server.new(server_params)

        if server.save
          Membership.create!(server: server, user_auth0_id: current_user_auth0_id, role: "owner")
          render json: server_response(server), status: :created
        else
          render json: { errors: server.errors.full_messages }, status: :unprocessable_entity
        end
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

      # メンバー一覧
      def members
        server = user_servers.find(params[:id])
        members = server.memberships.select(:id, :user_auth0_id, :role, :created_at)
        render json: members.map { |m| { id: m.id, auth0Id: m.user_auth0_id, role: m.role, joinedAt: m.created_at } }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Server not found or access denied" }, status: :not_found
      end

      # APIトークン生成（サーバーオーナーのみ）
      def generate_token
        server = user_servers.find(params[:id])
        membership = server.memberships.find_by(user_auth0_id: current_user_auth0_id)

        unless membership&.role == "owner"
          render json: { error: "Only server owners can generate API tokens" }, status: :forbidden
          return
        end

        token = server.generate_api_token!
        render json: { token: token }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Server not found or access denied" }, status: :not_found
      end

      # サーバー更新（名前変更など）
      def update
        server = user_servers.find(params[:id])
        membership = server.memberships.find_by(user_auth0_id: current_user_auth0_id)

        unless membership&.role == "owner"
          render json: { error: "Only server owners can update server settings" }, status: :forbidden
          return
        end

        if server.update(server_params)
          render json: server_response(server)
        else
          render json: { errors: server.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Server not found or access denied" }, status: :not_found
      end

      private

      def server_params
        params.require(:server).permit(:name)
      end

      def server_response(server)
        {
          id: server.id,
          name: server.name,
          inviteCode: server.invite_code,
          api_token: server.api_token,
          createdAt: server.created_at,
          updatedAt: server.updated_at
        }
      end
    end
  end
end
module Api
  module V1
    class MembersController < ApplicationController
      include RbacConcern
      
      before_action :authorize_request
      before_action :set_server
      before_action :require_server_member

      def index
        # メンバー一覧の閲覧権限をチェック
        return unless require_permission('read_messages', @server.id)
        memberships = @server.memberships.includes(:role_assignments => :server_role)
        
        # 全ユーザーのAuth0 IDを収集
        user_ids = memberships.map(&:user_auth0_id)
        
        # Auth0から一括でユーザー情報を取得
        auth0_service = Auth0Service.new
        users_info = auth0_service.get_users(user_ids)
        
        members = memberships.map do |membership|
          user_info = users_info[membership.user_auth0_id] || get_fallback_user_info(membership.user_auth0_id)
          {
            id: membership.id,
            userAuth0Id: membership.user_auth0_id,
            userName: user_info[:name],
            userEmail: user_info[:email],
            userPicture: user_info[:picture],
            role: membership.role,
            joinedAt: membership.created_at,
            roles: membership.role_assignments.map do |assignment|
              {
                id: assignment.server_role.id,
                name: assignment.server_role.name,
                color: assignment.server_role.color
              }
            end
          }
        end

        render json: { members: members }
      end

      def show
        return unless require_permission('read_messages', @server.id)
        
        membership = @server.memberships.find(params[:id])
        
        # Auth0からユーザー情報を取得
        auth0_service = Auth0Service.new
        user_info = auth0_service.get_user(membership.user_auth0_id) || get_fallback_user_info(membership.user_auth0_id)
        
        member_data = {
          id: membership.id,
          userAuth0Id: membership.user_auth0_id,
          userName: user_info[:name],
          userEmail: user_info[:email],
          userPicture: user_info[:picture],
          role: membership.role,
          joinedAt: membership.created_at,
          roles: membership.role_assignments.includes(:server_role).map do |assignment|
            {
              id: assignment.server_role.id,
              name: assignment.server_role.name,
              color: assignment.server_role.color,
              description: assignment.server_role.description
            }
          end
        }

        render json: member_data
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Member not found" }, status: :not_found
      end

      def me
        return unless require_permission('read_messages', @server.id)
        
        membership = @server.memberships.find_by(user_auth0_id: current_user_auth0_id)
        
        unless membership
          render json: { error: "Membership not found" }, status: :not_found
          return
        end

        # Auth0からユーザー情報を取得
        auth0_service = Auth0Service.new
        user_info = auth0_service.get_user(membership.user_auth0_id) || get_fallback_user_info(membership.user_auth0_id)
        
        member_data = {
          id: membership.id,
          userAuth0Id: membership.user_auth0_id,
          userName: user_info[:name],
          userEmail: user_info[:email],
          userPicture: user_info[:picture],
          role: membership.role,
          joinedAt: membership.created_at,
          roles: membership.role_assignments.includes(:server_role).map do |assignment|
            {
              id: assignment.server_role.id,
              name: assignment.server_role.name,
              color: assignment.server_role.color,
              description: assignment.server_role.description,
              permissionLevel: assignment.server_role.permission_level
            }
          end
        }

        # 権限情報を含めてレスポンス
        render json: include_permissions_in_response(member_data, @server.id)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Member not found" }, status: :not_found
      end

      private

      def set_server
        Rails.logger.info "MembersController Debug: current_user_auth0_id = #{current_user_auth0_id}"
        Rails.logger.info "MembersController Debug: requested server_id = #{params[:server_id]}"
        
        @server = Server.joins(:memberships)
                       .where(memberships: { user_auth0_id: current_user_auth0_id })
                       .find(params[:server_id])
        
        Rails.logger.info "MembersController Debug: Server found: #{@server.name}"
      rescue ActiveRecord::RecordNotFound
        Rails.logger.warn "MembersController Debug: Server not found or user not member"
        render json: { error: "Server not found or access denied" }, status: :not_found
      end

      def get_fallback_user_info(user_auth0_id)
        # Auth0 APIが失敗した場合のフォールバック
        provider_info = user_auth0_id.split('|')
        provider = provider_info[0]
        user_id = provider_info[1]
        
        case provider
        when 'google-oauth2'
          name = "Google User #{user_id[-4..-1]}"
        when 'github'
          name = "GitHub User #{user_id[-4..-1]}"
        when 'auth0'
          name = "User #{user_id}"
        else
          name = "User #{user_auth0_id[-4..-1]}"
        end
        
        {
          name: name,
          email: nil,
          picture: nil
        }
      rescue => e
        Rails.logger.error "Failed to generate fallback user info for #{user_auth0_id}: #{e.message}"
        {
          name: "Unknown User",
          email: nil,
          picture: nil
        }
      end
    end
  end
end
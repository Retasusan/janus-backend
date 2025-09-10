module Api
  module V1
    class RoleAssignmentsController < ApplicationController
      include RbacConcern
      before_action :authorize_request
      before_action :set_server

      # ロール割り当て（昇格・降格）
      def update
        return unless require_permission('manage_roles', @server.id)
        
        membership = @server.memberships.find_by(user_auth0_id: params[:user_auth0_id])
        unless membership
          render json: { error: 'User is not a member of this server' }, status: :not_found
          return
        end

        role = @server.server_roles.find(params[:role_id])
        
        # 既存のロール割り当てを削除
        membership.role_assignments.destroy_all
        
        # 新しいロールを割り当て
        membership.role_assignments.create!(server_role: role)
        
        render json: { 
          message: 'Role updated successfully',
          user_auth0_id: params[:user_auth0_id],
          new_role: {
            id: role.id,
            name: role.name,
            color: role.color,
            description: role.description
          }
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Role not found' }, status: :not_found
      end

      # ユーザーのロール一覧取得
      def show
        return unless require_permission('read_messages', @server.id)
        
        membership = @server.memberships.find_by(user_auth0_id: params[:user_auth0_id])
        unless membership
          render json: { error: 'User is not a member of this server' }, status: :not_found
          return
        end

        roles = membership.role_assignments.includes(:server_role).map do |assignment|
          {
            id: assignment.server_role.id,
            name: assignment.server_role.name,
            color: assignment.server_role.color,
            description: assignment.server_role.description
          }
        end

        render json: { 
          user_auth0_id: params[:user_auth0_id],
          roles: roles
        }
      end

      private
      
      def set_server
        @server = Server.find(params[:server_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Server not found' }, status: :not_found
      end
    end
  end
end

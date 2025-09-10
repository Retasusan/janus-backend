module Api
  module V1
    class ServerRolesController < ApplicationController
      include RbacConcern
      before_action :authorize_request
      before_action :set_server

      def index
        return unless require_permission('read_messages', @server.id) # 一般ユーザーもロール一覧は見れる
        roles = @server.server_roles.order(:position, :name)
        render json: roles.map { |role| role_response(role) }
      end

      def create
        return unless require_permission('manage_roles', @server.id) # Admin権限必要
        role = @server.server_roles.build(role_params)
        
        if role.save
          render json: role_response(role), status: :created
        else
          render json: { errors: role.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        return unless require_permission('manage_roles', @server.id) # Admin権限必要
        role = @server.server_roles.find(params[:id])
        
        if role.update(role_params)
          render json: role_response(role)
        else
          render json: { errors: role.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        return unless require_permission('manage_roles', @server.id) # Admin権限必要
        role = @server.server_roles.find(params[:id])
        
        if role.default_role?
          render json: { error: "Cannot delete default role" }, status: :unprocessable_entity
        else
          role.destroy
          head :no_content
        end
      end

      # ユーザーにロールを割り当て
      def assign_role
        return unless require_permission('manage_roles', @server.id) # Admin権限必要
        user_id = params[:userId] || params[:user_id]
        membership = @server.memberships.find_by(user_auth0_id: user_id)
        role = @server.server_roles.find(params[:id])
        
        unless membership
          render json: { error: "User not found in server" }, status: :not_found
          return
        end

        # 既存のロール割り当てを削除してから新しいロールを割り当て
        membership.role_assignments.destroy_all
        assignment = RoleAssignment.create!(
          membership: membership,
          server_role: role
        )

        render json: { 
          message: "Role assigned successfully",
          assignment: {
            id: assignment.id,
            userId: membership.user_auth0_id,
            roleId: role.id,
            roleName: role.name
          }
        }
      end

      # ユーザーからロールを削除
      def remove_role
        return unless require_permission('manage_roles', @server.id) # Admin権限必要
        user_id = params[:userId] || params[:user_id]
        membership = @server.memberships.find_by(user_auth0_id: user_id)
        role = @server.server_roles.find(params[:id])
        
        unless membership
          render json: { error: "User not found in server" }, status: :not_found
          return
        end

        assignment = RoleAssignment.find_by(membership: membership, server_role: role)
        
        if assignment
          assignment.destroy
          render json: { message: "Role removed successfully" }
        else
          render json: { error: "Role assignment not found" }, status: :not_found
        end
      end

      private

      def role_params
        params.permit(:name, :color, :description, :position, :mentionable, :hoist)
      end

      def role_response(role)
        {
          id: role.id,
          serverId: role.server_id,
          name: role.name,
          color: role.color,
          description: role.description,
          position: role.position,
          mentionable: role.mentionable,
          hoist: role.hoist,
          permissionLevel: role.permission_level,
          defaultRole: role.default_role?,
          memberCount: role.role_assignments.count,
          permissions: get_role_permissions(role),
          createdAt: role.created_at,
          updatedAt: role.updated_at
        }
      end

      def get_role_permissions(role)
        RbacService.permissions.map do |permission, required_level|
          {
            name: permission,
            description: RbacService.permission_description(permission),
            hasPermission: role.permission_level >= required_level,
            required_level: required_level
          }
        end
      end
    end
  end
end
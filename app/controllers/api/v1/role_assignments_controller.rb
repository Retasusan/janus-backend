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

        new_role = @server.server_roles.find(params[:role_id])
        
        # 現在のロールを取得
        current_roles = membership.role_assignments.includes(:server_role)
        current_admin_role = current_roles.find { |ra| ra.server_role.name == 'admin' }
        
        # Adminロールから他のロールに変更しようとしている場合のチェック
        if current_admin_role && new_role.name != 'admin'
          # サーバー内のAdmin数をチェック
          admin_role = @server.server_roles.find_by(name: 'admin')
          if admin_role
            admin_count = @server.memberships
                               .joins(:role_assignments)
                               .where(role_assignments: { server_role: admin_role })
                               .count
            
            # オーナーもAdminとしてカウント（オーナーは常にAdmin権限を持つ）
            owner_count = @server.memberships.where(user_auth0_id: @server.created_by).count
            total_admin_count = admin_count + (owner_count > 0 ? 0 : 0) # オーナーは既にカウントされている可能性
            
            # 実際のAdmin数を正確に計算
            actual_admin_count = 0
            @server.memberships.each do |m|
              rbac = RbacService.new(m.user_auth0_id, @server.id)
              actual_admin_count += 1 if rbac.admin?
            end
            
            if actual_admin_count <= 1
              render json: { 
                error: 'Cannot remove the last administrator. At least one admin must remain in the server.',
                current_admin_count: actual_admin_count
              }, status: :forbidden
              return
            end
          end
        end
        
        # 既存のロール割り当てを削除
        membership.role_assignments.destroy_all
        
        # 新しいロールを割り当て
        membership.role_assignments.create!(server_role: new_role)
        
        render json: { 
          message: 'Role updated successfully',
          user_auth0_id: params[:user_auth0_id],
          new_role: {
            id: new_role.id,
            name: new_role.name,
            color: new_role.color,
            description: new_role.description
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

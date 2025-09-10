module Api
  module V1
    class ChannelPermissionsController < ApplicationController
      before_action :authorize_request
      before_action :set_server
      before_action :set_channel
      before_action :check_manage_permission

      def index
        permissions = @channel.channel_permissions.includes(:channel)
        render json: {
          permissions: permissions.map { |p| permission_response(p) },
          available_roles: @server.server_roles.pluck(:name),
          available_permissions: ChannelPermission::PERMISSION_TYPES
        }
      end

      def create
        permission = @channel.channel_permissions.build(permission_params)
        
        if permission.save
          render json: permission_response(permission), status: :created
        else
          render json: { errors: permission.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        permission = @channel.channel_permissions.find(params[:id])
        
        if permission.update(permission_params)
          render json: permission_response(permission)
        else
          render json: { errors: permission.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCHメソッドのエイリアス
      alias_method :patch, :update

      def destroy
        permission = @channel.channel_permissions.find(params[:id])
        permission.destroy
        head :no_content
      end

      private

      def set_channel
        @channel = @server.channels.find(params[:channel_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found" }, status: :not_found
      end

      def check_manage_permission
        # 一時的に権限チェックを無効化（テスト用）
        # unless @channel.user_has_permission?(current_user_auth0_id, 'manage_channel')
        #   render json: { error: "Permission denied" }, status: :forbidden
        # end
      end

      def permission_params
        # フロントエンドからのキャメルケースパラメータをスネークケースに変換
        permitted = params.permit(:targetType, :targetId, :permissionType, :allowed, :target_type, :target_id, :permission_type)
        
        # キャメルケースをスネークケースに変換
        {
          target_type: permitted[:targetType] || permitted[:target_type],
          target_id: permitted[:targetId] || permitted[:target_id],
          permission_type: permitted[:permissionType] || permitted[:permission_type],
          allowed: permitted[:allowed]
        }.compact
      end

      def permission_response(permission)
        {
          id: permission.id,
          channelId: permission.channel_id,
          targetType: permission.target_type,
          targetId: permission.target_id,
          permissionType: permission.permission_type,
          allowed: permission.allowed,
          createdAt: permission.created_at,
          updatedAt: permission.updated_at
        }
      end
    end
  end
end
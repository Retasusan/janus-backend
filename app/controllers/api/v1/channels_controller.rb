module Api
  module V1
    class ChannelsController < ApplicationController
      include RbacConcern
      
      before_action :authorize_request
      before_action :set_server
      before_action :require_server_member

      def index
        return unless require_permission('read_messages', @server.id)
        
        channels = @server.channels
        response_data = { channels: channels.map { |channel| channel_response(channel) } }
        
        # 権限情報を含めてレスポンス
        render json: include_permissions_in_response(response_data, @server.id)
      end

      def show
        return unless require_permission('read_messages', @server.id, params[:id])
        
        channel = @server.channels.find(params[:id])
        response_data = channel_response(channel)
        
        render json: include_permissions_in_response(response_data, @server.id, params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found" }, status: :not_found
      end

      def create
        return unless require_permission('manage_channels', @server.id)
        
        channel = @server.channels.new(channel_params)

        if channel.save
          render json: channel_response(channel), status: :created
        else
          render json: { errors: channel.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        return unless require_permission('manage_channels', @server.id)
        
        channel = @server.channels.find(params[:id])
        
        if channel.update(channel_params)
          render json: channel_response(channel)
        else
          render json: { errors: channel.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found" }, status: :not_found
      end

      def destroy
        return unless require_permission('manage_channels', @server.id)
        
        channel = @server.channels.find(params[:id])
        channel.destroy
        
        render json: { message: "Channel deleted successfully" }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found" }, status: :not_found
      end

      private

      def set_server
        @server = user_servers.find(params[:server_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Server not found or access denied" }, status: :not_found
      end

      def channel_params
        params.permit(:name, :type, :description, settings: {})
      end

      def channel_response(channel)
        {
          id: channel.id,
          name: channel.name,
          serverId: channel.server_id,
          type: channel.type,
          description: channel.description,
          settings: channel.settings,
          createdAt: channel.created_at,
          updatedAt: channel.updated_at
        }
      end
    end
  end
end

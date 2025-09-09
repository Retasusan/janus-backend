module Api
  module V1
    class ChannelsController < ApplicationController
      before_action :authorize_request
      before_action :set_server

      def index
        channels = @server.channels
        render json: channels.map { |channel| channel_response(channel) }
      end

      def create
        channel = @server.channels.new(channel_params)

        if channel.save
          render json: channel_response(channel), status: :created
        else
          render json: { errors: channel.errors.full_messages }, status: :unprocessable_entity
        end
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

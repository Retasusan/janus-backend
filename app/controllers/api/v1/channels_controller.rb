module Api
  module V1
    class ChannelsController < ApplicationController
      before_action :authorize_request
      before_action :set_server

      def index
        channels = @server.channels
        render json: channels
      end

      def create
        channel = @server.channels.new(channel_params)

        if channel.save
          render json: channel, status: :created
        else
          render json: { errors: channel.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_server
        @server = Server.find(params[:server_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Server not found" }, status: :not_found
      end

      def channel_params
        params.permit(:name)
      end
    end
  end
end

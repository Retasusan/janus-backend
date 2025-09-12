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
  attrs = channel_params
  attrs[:channel_type] = attrs.delete(:type) if attrs.key?(:type)
  channel = @server.channels.new(attrs)

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
        # support both flat and nested { channel: { ... } }
        permitted = [:name, :type, :description, { settings: {} }]
        if params[:channel].is_a?(ActionController::Parameters)
          result = params.require(:channel).permit(permitted)
        else
          result = params.permit(permitted)
        end

        # Some clients send type at the top-level while the rest of the attrs are nested
        # under `channel`. If that's the case, prefer the provided top-level `type` so
        # we don't accidentally fall back to the DB default ('text').
        result[:type] = params[:type] if result[:type].blank? && params[:type].present?

        result
      end

      def channel_response(channel)
        {
          id: channel.id,
          name: channel.name,
          serverId: channel.server_id,
          # ensure type is a string that frontend expects; fallback to 'text' when missing/invalid
          type: (channel.type.presence || 'text').to_s,
          description: channel.description,
          settings: channel.settings,
          createdAt: channel.created_at,
          updatedAt: channel.updated_at
        }
      end
    end
  end
end

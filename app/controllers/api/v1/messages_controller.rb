module Api
  module V1
    class MessagesController < ApplicationController
      before_action :authorize_request
      before_action :set_channel

      def index
        @messages = @channel.messages.order(created_at: :asc)
        render json: @messages.map { |m| message_response(m) }
      end

      def create
  message = @channel.messages.new(message_params.merge(user_auth0_id: current_user_auth0_id))

        if message.save
          render json: message_response(message), status: :created
        else
          render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_channel
        @channel = user_channels.find(params[:channel_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found or access denied" }, status: :not_found
      end

      def message_params
        # Accept both {message: {content}} and {content}
        payload = params[:message].is_a?(ActionController::Parameters) ? params.require(:message) : params
        payload.permit(:content)
      end

      def message_response(m)
        # Get user profile for display name and avatar
        profile = UserProfile.find_by(auth0_id: m.user_auth0_id)
        
        {
          id: m.id,
          content: m.content,
          author: {
            auth0_id: m.user_auth0_id,
            display_name: profile&.display_name || "Unknown User",
            avatar_url: profile&.avatar_url
          },
          createdAt: m.created_at,
          channelId: m.channel_id
        }
      end
    end
  end
end
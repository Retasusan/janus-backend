module Api
  module V1
    class MessagesController < ApplicationController
  include RbacConcern
  before_action :authorize_request
  before_action :set_channel

      def index
  return unless require_permission('read_messages', @channel.server_id, @channel.id)
  @messages = @channel.messages.order(created_at: :asc)
  render json: @messages
      end

      def create
        return unless require_permission('send_messages', @channel.server_id, @channel.id)
        message = @channel.messages.new(message_params.merge(user_auth0_id: current_user_auth0_id))

        if message.save
          render json: message, status: :created
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
        params.require(:message).permit(:content)
      end
    end
  end
end
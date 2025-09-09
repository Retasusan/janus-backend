module Api
  module V1
    class MessagesController < ApplicationController
      before_action :authorize_request
      before_action :set_channel

      def index
        channel = Channel.find(params[:channel_id])
        @messages = channel.messages.order(created_at: :asc)
        render json: @messages
      end

      def create
        message = @channel.messages.new(message_params.merge(user_auth0_id: current_user_auth0_id))

        if message.save
          render json: message, status: :created
        else
          render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private
    end
  end
end
module Api
  module V1
    class WhiteboardsController < ApplicationController
      before_action :authorize_request
      before_action :set_channel

      def index
        render json: @channel.whiteboards.order(updated_at: :desc)
      end

      def create
        payload = params[:whiteboard] || params
        wb = @channel.whiteboards.new(operations: payload[:operations] || {}, updated_by: current_user_auth0_id)
        if wb.save
          # return full list to match FE setState expectations
          render json: @channel.whiteboards.order(updated_at: :desc), status: :created
        else
          render json: { errors: wb.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private
      def set_channel
        @channel = user_channels.find(params[:channel_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found or access denied" }, status: :not_found
      end
    end
  end
end

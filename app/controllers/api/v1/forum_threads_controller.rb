module Api
  module V1
    class ForumThreadsController < ApplicationController
      before_action :authorize_request
      before_action :set_channel

      def index
        render json: @channel.forum_threads.order(created_at: :desc)
      end

      def create
        thread = @channel.forum_threads.new(title: params[:title], created_by: current_user_auth0_id)
        if thread.save
          render json: thread, status: :created
        else
          render json: { errors: thread.errors.full_messages }, status: :unprocessable_entity
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

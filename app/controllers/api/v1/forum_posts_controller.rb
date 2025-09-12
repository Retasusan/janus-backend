module Api
  module V1
    class ForumPostsController < ApplicationController
      before_action :authorize_request
      before_action :set_thread

      def index
        render json: @thread.forum_posts.order(created_at: :asc)
      end

      def create
        post = @thread.forum_posts.new(content: params[:content], created_by: current_user_auth0_id)
        if post.save
          render json: post, status: :created
        else
          render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private
      def set_thread
        channel = user_channels.find(params[:channel_id])
        @thread = channel.forum_threads.find(params[:forum_thread_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Thread not found or access denied" }, status: :not_found
      end
    end
  end
end

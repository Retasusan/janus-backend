module Api
  module V1
    class WikiPagesController < ApplicationController
      before_action :authorize_request
      before_action :set_channel

      def index
        render json: @channel.wiki_pages.order(updated_at: :desc)
      end

      def show
        page = @channel.wiki_pages.find(params[:id])
        render json: page
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Page not found" }, status: :not_found
      end

      def create
        page = @channel.wiki_pages.new(wiki_params.merge(user_auth0_id: current_user_auth0_id))
        if page.save
          render json: @channel.wiki_pages.order(updated_at: :desc), status: :created
        else
          render json: { errors: page.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        page = @channel.wiki_pages.find(params[:id])
        if page.update(wiki_params)
          render json: @channel.wiki_pages.order(updated_at: :desc)
        else
          render json: { errors: page.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private
      def set_channel
        @channel = user_channels.find(params[:channel_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found or access denied" }, status: :not_found
      end

      def wiki_params
        params.require(:wiki_page).permit(:title, :content)
      end
    end
  end
end

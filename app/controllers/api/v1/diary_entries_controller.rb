module Api
  module V1
    class DiaryEntriesController < ApplicationController
      before_action :authorize_request
      before_action :set_channel

      def index
        render json: @channel.diary_entries.order(entry_date: :desc)
      end

      def create
        entry = @channel.diary_entries.new(diary_params.merge(created_by: current_user_auth0_id))
        if entry.save
          render json: @channel.diary_entries.order(entry_date: :desc), status: :created
        else
          render json: { errors: entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private
      def set_channel
        @channel = user_channels.find(params[:channel_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found or access denied" }, status: :not_found
      end

      def diary_params
        params.require(:diary_entry).permit(:title, :content, :entry_date)
      end
    end
  end
end

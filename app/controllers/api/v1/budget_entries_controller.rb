module Api
  module V1
    class BudgetEntriesController < ApplicationController
      before_action :authorize_request
      before_action :set_channel

      def index
        render json: @channel.budget_entries.order(occurred_on: :desc)
      end

      def create
        entry = @channel.budget_entries.new(budget_params.merge(created_by: current_user_auth0_id))
        if entry.save
          render json: @channel.budget_entries.order(occurred_on: :desc), status: :created
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

      def budget_params
        params.require(:budget_entry).permit(:kind, :title, :amount, :occurred_on)
      end
    end
  end
end

module Api
  module V1
    class InventoryItemsController < ApplicationController
      before_action :authorize_request
      before_action :set_channel

      def index
        render json: @channel.inventory_items.order(updated_at: :desc)
      end

      def create
        item = @channel.inventory_items.new(item_params.merge(updated_by: current_user_auth0_id))
        if item.save
          render json: @channel.inventory_items.order(updated_at: :desc), status: :created
        else
          render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private
      def set_channel
        @channel = user_channels.find(params[:channel_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found or access denied" }, status: :not_found
      end

      def item_params
        params.require(:inventory_item).permit(:name, :quantity, :location)
      end
    end
  end
end

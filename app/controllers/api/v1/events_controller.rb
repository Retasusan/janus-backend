module Api
  module V1
    class EventsController < ApplicationController
      before_action :authorize_request
      before_action :set_channel

      # GET /servers/:server_id/channels/:channel_id/events?year=YYYY&month=MM
      def index
        year = params[:year].to_i
        month = params[:month].to_i

        scope = @channel.events.order(start_at: :asc)
        if year.positive? && month.positive?
          from = Time.utc(year, month, 1)
          to = (from + 1.month)
          scope = scope.where("start_at >= ? AND start_at < ?", from, to)
        end

        render json: scope.map { |e| event_response(e) }
      end

      # POST /servers/:server_id/channels/:channel_id/events
      def create
        # 柔軟な入力に対応（{event:{...}} もしくはフラット）
        payload = params[:event] || params
        event = @channel.events.new(
          title: payload[:title],
          description: payload[:description],
          start_at: payload[:start_at] || payload[:startDate],
          end_at: payload[:end_at] || payload[:endDate]
        )
        event.user_auth0_id = current_user_auth0_id

        if event.save
          render json: event_response(event), status: :created
        else
          render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_channel
        @channel = user_channels.find(params[:channel_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found or access denied" }, status: :not_found
      end

      def event_response(event)
        {
          id: event.id,
          title: event.title,
          description: event.description,
          startDate: event.start_at&.iso8601,
          endDate: event.end_at&.iso8601,
          allDay: false,
          createdBy: event.user_auth0_id,
          createdAt: event.created_at,
        }
      end
    end
  end
end

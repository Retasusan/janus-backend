module Api
  module V1
    class TasksController < ApplicationController
      before_action :authorize_request
      before_action :set_channel

      def index
        render json: @channel.tasks.order(created_at: :desc)
      end

      def create
        task = @channel.tasks.new(task_params.merge(created_by: current_user_auth0_id))
        task.status ||= Task::STATUS_TODO
        if task.save
          render json: @channel.tasks.order(created_at: :desc), status: :created
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        task = @channel.tasks.find(params[:id])
        if task.update(task_params)
          render json: @channel.tasks.order(created_at: :desc)
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private
      def set_channel
        @channel = user_channels.find(params[:channel_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found or access denied" }, status: :not_found
      end

      def task_params
        params.require(:task).permit(:title, :description, :status, :due_date, :assignee)
      end
    end
  end
end

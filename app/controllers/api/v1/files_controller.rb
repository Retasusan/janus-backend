module Api
  module V1
    class FilesController < ApplicationController
      include Rails.application.routes.url_helpers

      before_action :authorize_request
      before_action :set_channel
      before_action :set_file_record, only: [:download]

      # GET /servers/:server_id/channels/:channel_id/files
      def index
        files = @channel.channel_files.order(created_at: :desc)
        render json: files.map { |f| file_response(f) }
      end

      # POST multipart form-data { file }
      def create
        unless params[:file].present?
          render json: { error: "file is required" }, status: :bad_request
          return
        end

        cf = @channel.channel_files.new(uploaded_by: current_user_auth0_id)
        cf.file.attach(params[:file])

        if cf.save
          render json: file_response(cf), status: :created
        else
          render json: { errors: cf.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /servers/:server_id/channels/:channel_id/files/:id/download
      def download
        if @file.file.attached?
          redirect_to rails_blob_url(@file.file, host: request.base_url)
        else
          render json: { error: "File not found" }, status: :not_found
        end
      end

      private

      def set_channel
        @channel = user_channels.find(params[:channel_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found or access denied" }, status: :not_found
      end

      def set_file_record
        @file = @channel.channel_files.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "File not found" }, status: :not_found
      end

      def file_response(cf)
        blob = cf.file.attachment&.blob
        {
          id: cf.id,
          filename: blob&.filename&.to_s,
          size: blob&.byte_size || 0,
          mimeType: blob&.content_type,
          uploadedBy: cf.uploaded_by,
          uploadedAt: cf.created_at,
          downloadUrl: download_api_v1_server_channel_file_url(
            server_id: cf.channel.server_id,
            channel_id: cf.channel_id,
            id: cf.id,
            host: request.base_url
          )
        }
      end
    end
  end
end

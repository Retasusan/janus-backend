module Api
  module V1
    class PhotosController < ApplicationController
      include Rails.application.routes.url_helpers

      before_action :authorize_request
      before_action :set_channel
      before_action :set_photo, only: [:download]

      def index
        photos = @channel.photos.order(created_at: :desc)
        render json: photos.map { |p| serialize(p) }
      end

      def create
        # Accept both flat and nested params: { image, caption } or { photo: { image, caption } }
        image_param = params.dig(:photo, :image) || params[:image]
        caption_param = params.dig(:photo, :caption) || params[:caption]

        unless image_param.present?
          render json: { error: "image is required" }, status: :bad_request
          return
        end

        ph = @channel.photos.new(uploaded_by: current_user_auth0_id, caption: caption_param)
        ph.image.attach(image_param)
        if ph.save
          # Return created photo (frontend appends it into the list)
          render json: serialize(ph), status: :created
        else
          render json: { errors: ph.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def download
        if @photo.image.attached?
          redirect_to rails_blob_url(@photo.image, host: request.base_url)
        else
          render json: { error: "Not found" }, status: :not_found
        end
      end

      private
      def set_channel
        @channel = user_channels.find(params[:channel_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found or access denied" }, status: :not_found
      end

      def set_photo
        @photo = @channel.photos.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Photo not found" }, status: :not_found
      end

      def serialize(p)
        {
          id: p.id,
          caption: p.caption,
          uploadedBy: p.uploaded_by,
          uploadedAt: p.created_at,
          downloadUrl: download_api_v1_server_channel_photo_url(server_id: p.channel.server_id, channel_id: p.channel_id, id: p.id, host: request.base_url)
        }
      end
    end
  end
end

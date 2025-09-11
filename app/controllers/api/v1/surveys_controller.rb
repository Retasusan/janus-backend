module Api
  module V1
    class SurveysController < ApplicationController
      before_action :authorize_request
      before_action :set_channel

      def index
  surveys = @channel.surveys.includes(:survey_options)
  render json: surveys.map { |s| survey_response(s) }
      end

      def create
        # normalize survey_options_attributes: support single textarea with newlines or commas
        if params[:survey].present? && params[:survey][:survey_options_attributes].is_a?(Array) && params[:survey][:survey_options_attributes].length == 1
          raw_text = params[:survey][:survey_options_attributes][0][:text] || params[:survey][:survey_options_attributes][0]['text']
          if raw_text.present?
            parts = raw_text.split(/\r?\n|,/).map(&:strip).reject(&:empty?)
            if parts.length > 1
              params[:survey][:survey_options_attributes] = parts.map { |t| { text: t } }
            end
          end
        end

        survey = @channel.surveys.new(survey_params.merge(created_by: current_user_auth0_id))
        if survey.save
          surveys = @channel.surveys.includes(:survey_options)
          render json: surveys.map { |s| survey_response(s) }, status: :created
        else
          render json: { errors: survey.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def vote
        survey = @channel.surveys.find(params[:id])
        option = survey.survey_options.find(params[:option_id])
        vote = survey.survey_votes.find_or_initialize_by(voter: current_user_auth0_id)
        vote.survey_option = option
        if vote.save
          surveys = @channel.surveys.includes(:survey_options)
          render json: surveys.map { |s| survey_response(s) }
        else
          render json: { errors: vote.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private
      def set_channel
        @channel = user_channels.find(params[:channel_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Channel not found or access denied" }, status: :not_found
      end

      def survey_params
        params.require(:survey).permit(:question, :multiple, :expires_at, survey_options_attributes: [:text])
      end

      def survey_response(survey)
        opts = survey.survey_options.map do |o|
          {
            id: o.id,
            text: o.text,
            votes_count: survey.survey_votes.where(survey_option_id: o.id).count
          }
        end

        {
          id: survey.id,
          question: survey.question,
          multiple: survey.multiple,
          expires_at: survey.expires_at,
          survey_options: opts,
          created_at: survey.created_at,
          updated_at: survey.updated_at
        }
      end
    end
  end
end

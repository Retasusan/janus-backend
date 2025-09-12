module Api
  module V1
    class UsersController < ApplicationController
      include Authenticatable

      # GET /users/me
      def me
        render json: {
          auth0_id: current_user_auth0_id,
          name: current_user_name,
          email: current_user_email
        }
      end

      # GET /users/profile
      def profile
        profile = UserProfile.find_or_create_for_auth0_id(
          current_user_auth0_id,
          default_name: current_user_name
        )
        
        render json: {
          auth0_id: profile.auth0_id,
          display_name: profile.display_name,
          avatar_url: profile.avatar_url
        }
      end

      # PUT /users/profile
      def update_profile
        profile = UserProfile.find_or_create_for_auth0_id(
          current_user_auth0_id,
          default_name: current_user_name
        )

        if profile.update(profile_params)
          render json: {
            auth0_id: profile.auth0_id,
            display_name: profile.display_name,
            avatar_url: profile.avatar_url
          }
        else
          render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.permit(:display_name, :avatar_url)
      end
    end
  end
end

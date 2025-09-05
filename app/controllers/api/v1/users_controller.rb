module Api
  module V1
    class UsersController < ApplicationController
      include Authenticatable

      # GET /users/me
      def me
        token = request.headers["Authorization"]&.split(" ")&.last
        return render json: { error: "Missing token" }, status: :unauthorized unless token

        url = URI("https://#{ENV['AUTH0_DOMAIN']}/userinfo")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        req = Net::HTTP::Get.new(url)
        req["Accept"] = "application/json"
        req["Authorization"] = "Bearer #{token}"  # ←ここがポイント

        res = https.request(req)
        if res.is_a?(Net::HTTPSuccess)
          user_info = JSON.parse(res.body)

          # ユーザーがDBにいるか確認
          user = User.find_or_initialize_by(auth0_id: user_info["sub"])
          user.name = user_info["name"]
          user.email = user_info["email"]
          user.save!

          render json: user
        else
          render json: { error: "Failed to fetch user info" }, status: :unauthorized
        end
      end
    end
  end
end

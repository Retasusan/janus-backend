module Api
  module V1
    class ServersController < ApplicationController
      before_action :authorize_request

      # サーバー一覧（所属しているサーバーのみ）
      def index
        servers = user_servers
        render json: servers
      end

      # サーバー作成
      def create
        server = Server.new(server_params)

        if server.save
          Membership.create!(server: server, user_auth0_id: current_user_auth0_id, role: "owner")
          render json: server, status: :created
        else
          render json: { errors: server.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def server_params
        params.require(:server).permit(:name, :description)
      end
    end
  end
end
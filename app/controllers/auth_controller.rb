class AuthController < ApplicationController
  def verify_token
    render json: { message: "Token is valid" }, status: :ok
  end
end
class ApplicationController < ActionController::API
  include Authenticatable
  private

  def current_user_auth0_id
    @current_user&.dig("sub")
  end
end

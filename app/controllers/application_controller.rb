class ApplicationController < ActionController::API
  include Authenticatable
  private

  def current_user_auth0_id
    @current_user&.dig("sub")
  end

  # ユーザーが所属しているサーバーのみを取得
  def user_servers
    Server.joins(:memberships)
          .where(memberships: { user_auth0_id: current_user_auth0_id })
  end

  # ユーザーが所属しているサーバーのチャンネルのみを取得
  def user_channels
    Channel.joins(server: :memberships)
           .where(memberships: { user_auth0_id: current_user_auth0_id })
  end
end

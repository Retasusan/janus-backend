class ApplicationController < ActionController::API
  include ServerTokenAuthenticatable
  include Authenticatable
  
  private

  def current_user_auth0_id
    if server_token_authenticated?
      # サーバートークン認証時は、サーバーのオーナーのIDを返す
      owner_membership = current_server.memberships.find_by(role: "owner")
      return owner_membership&.user_auth0_id || "system"
    end
    
    @current_user&.dig("sub")
  end

  # ユーザーが所属しているサーバーのみを取得
  def user_servers
    if server_token_authenticated?
      # サーバートークン認証時は、そのサーバーのみ返す
      Server.where(id: current_server.id)
    else
      # 通常のAuth0認証時は、所属しているサーバーを返す
      Server.joins(:memberships)
            .where(memberships: { user_auth0_id: current_user_auth0_id })
    end
  end

  # ユーザーが所属しているサーバーのチャンネルのみを取得
  def user_channels
    if server_token_authenticated?
      # サーバートークン認証時は、そのサーバーのチャンネルのみ返す
      Channel.where(server: current_server)
    else
      # 通常のAuth0認証時は、所属しているサーバーのチャンネルを返す
      Channel.joins(server: :memberships)
             .where(memberships: { user_auth0_id: current_user_auth0_id })
    end
  end
end

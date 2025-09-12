module ServerTokenAuthenticatable
  extend ActiveSupport::Concern

  included do
    prepend_before_action :authenticate_with_server_token_if_present
  end

  private

  def authenticate_with_server_token_if_present
    # サーバートークンがある場合は、それで認証
    server_token = extract_server_token
    
    if server_token
      @current_server = Server.find_by_api_token(server_token)
      
      unless @current_server
        render json: { error: "Invalid server token" }, status: :unauthorized
        return false
      end
      
      # サーバートークン認証が成功した場合、後続の認証をスキップ
      @server_token_authenticated = true
      # authorize_requestをスキップするためのフラグを設定
      @skip_auth0_check = true
      return true
    end
    
    # サーバートークンがない場合は通常のAuth0認証を実行
    false
  end

  def extract_server_token
    # X-Server-Token ヘッダーから取得
    if request.headers["X-Server-Token"].present?
      return request.headers["X-Server-Token"]
    end
    
    # Authorization: Token <token> 形式から取得
    auth_header = request.headers["Authorization"]
    if auth_header&.start_with?("Token ")
      return auth_header.split(" ", 2).last
    end
    
    nil
  end

  def server_token_authenticated?
    @server_token_authenticated == true
  end

  def current_server
    @current_server
  end

  def current_server_id
    @current_server&.id
  end

  # サーバートークン認証時のユーザー情報（システムユーザーとして扱う）
  def current_user_auth0_id
    if server_token_authenticated?
      # サーバートークン使用時は、サーバーのオーナーとして扱う
      owner_membership = @current_server.memberships.find_by(role: "owner")
      return owner_membership&.user_auth0_id || "system"
    end
    
    super if defined?(super)
  end
end

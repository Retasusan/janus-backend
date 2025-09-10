module RbacConcern
  extend ActiveSupport::Concern

  included do
    before_action :initialize_rbac_service, if: :current_user_auth0_id
  end

  private

  def initialize_rbac_service
    @rbac_service = RbacService.new(current_user_auth0_id, params[:server_id])
  end

  # 権限チェック
  def require_permission(permission, server_id = nil, channel_id = nil)
    unless current_user_auth0_id
      render json: { error: "Authentication required" }, status: :unauthorized
      return false
    end

    Rails.logger.info "RBAC Debug: Checking permission '#{permission}' for user '#{current_user_auth0_id}', server_id=#{server_id}"

    # サーバーIDが指定されている場合は、そのサーバー用のRBACサービスを作成
    rbac = server_id ? RbacService.new(current_user_auth0_id, server_id) : @rbac_service

    unless rbac&.can?(permission, channel_id)
      Rails.logger.warn "RBAC Debug: Permission denied - user '#{current_user_auth0_id}' lacks '#{permission}' permission"
      render json: { 
        error: "Insufficient permissions", 
        required_permission: permission,
        description: RbacService.permission_description(permission)
      }, status: :forbidden
      return false
    end

    true
  end

  # 管理者権限チェック
  def require_admin(server_id = nil)
    require_permission('manage_server', server_id)
  end

  # モデレーター権限チェック
  def require_moderator(server_id = nil)
    unless current_user_auth0_id
      render json: { error: "Authentication required" }, status: :unauthorized
      return false
    end

    rbac = server_id ? RbacService.new(current_user_auth0_id, server_id) : @rbac_service
    
    unless rbac&.moderator?
      render json: { error: "Moderator permissions required" }, status: :forbidden
      return false
    end

    true
  end

  # サーバーメンバーかどうかチェック
  def require_server_member(server_id = nil)
    target_server_id = server_id || params[:server_id]
    
    unless current_user_auth0_id
      render json: { error: "Authentication required" }, status: :unauthorized
      return false
    end

    membership = Membership.find_by(
      server_id: target_server_id,
      user_auth0_id: current_user_auth0_id
    )

    unless membership
      render json: { error: "Server membership required" }, status: :forbidden
      return false
    end

    true
  end

  # 現在のユーザーのRBACサービスを取得
  def current_rbac
    @rbac_service
  end

  # 権限情報をレスポンスに含める
  def include_permissions_in_response(data, server_id = nil, channel_id = nil)
    return data unless current_user_auth0_id

    rbac = server_id ? RbacService.new(current_user_auth0_id, server_id) : @rbac_service
    return data unless rbac

    permissions = {}
    RbacService.permissions.each do |permission, _level|
      permissions[permission] = rbac.can?(permission, channel_id)
    end

    data.merge({
      user_permissions: permissions,
      user_roles: rbac.get_user_roles,
      max_permission_level: rbac.get_user_permission_level(channel_id)
    })
  end
end
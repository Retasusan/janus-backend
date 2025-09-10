class RbacService
  # 権限レベル定義
  PERMISSION_LEVELS = {
    'guest' => 1,
    'ob' => 2,
    'readonly' => 3,
    'member' => 10,
    'moderator' => 50,
    'admin' => 100
  }.freeze

  # 権限定義 - 各アクションに必要な最小権限レベル
  PERMISSIONS = {
    # サーバー権限
    'manage_server' => 100,       # adminのみ
    'manage_channels' => 50,      # moderator以上
    'manage_roles' => 100,        # adminのみ
    'invite_users' => 10,         # member以上
    'kick_users' => 50,           # moderator以上
    'ban_users' => 50,            # moderator以上
    
    # チャンネル権限
    'read_messages' => 1,         # guest以上（全員）
    'send_messages' => 10,        # member以上（readonly/obは投稿不可）
    'manage_messages' => 50,      # moderator以上
    'read_files' => 1,            # guest以上（全員）
    'upload_files' => 10,         # member以上
    'manage_files' => 50,         # moderator以上
    'manage_channel' => 50        # moderator以上
  }.freeze

  def initialize(user_auth0_id, server_id = nil)
    @user_auth0_id = user_auth0_id
    @server_id = server_id
  end

  # ユーザーが特定の権限を持っているかチェック
  def can?(permission, channel_id = nil)
    required_level = PERMISSIONS[permission]
    return false unless required_level

    user_level = get_user_permission_level(channel_id)
    user_level >= required_level
  end

  # ユーザーの最大権限レベルを取得
  def get_user_permission_level(channel_id = nil)
    return 0 unless @server_id

    Rails.logger.info "RBAC Debug: Getting permission level for user_id=#{@user_auth0_id}, server_id=#{@server_id}"

    # サーバーオーナーかどうかチェック
    if server_owner?
      Rails.logger.info "RBAC Debug: User is owner, returning admin level (100)"
      return PERMISSION_LEVELS['admin']  # オーナーは無条件で管理者権限
    end

    # サーバーメンバーシップを取得
    membership = Membership.find_by(
      server_id: @server_id,
      user_auth0_id: @user_auth0_id
    )
    
    unless membership
      Rails.logger.info "RBAC Debug: No membership found, returning 0"
      return 0
    end

    # ロール割り当てから最大権限レベルを取得
    max_level = membership.role_assignments
                          .includes(:server_role)
                          .map { |assignment| assignment.server_role.permission_level }
                          .max || 0

    Rails.logger.info "RBAC Debug: Max level from role assignments: #{max_level}"

    # チャンネル固有の権限があれば考慮
    if channel_id
      channel_level = get_channel_permission_level(channel_id)
      max_level = [max_level, channel_level].max
    end

    Rails.logger.info "RBAC Debug: Final permission level: #{max_level}"
    max_level
  end

  # ユーザーのロール一覧を取得
  def get_user_roles
    return [] unless @server_id

    membership = Membership.find_by(
      server_id: @server_id,
      user_auth0_id: @user_auth0_id
    )
    return [] unless membership

    membership.role_assignments.includes(:server_role).map do |assignment|
      {
        id: assignment.server_role.id,
        name: assignment.server_role.name,
        color: assignment.server_role.color,
        permissionLevel: assignment.server_role.permission_level,
        description: assignment.server_role.description
      }
    end
  end

  # 管理者かどうか
  def admin?
    can?('manage_server')
  end

  # サーバーオーナーかどうか
  def owner?
    server_owner?
  end

  # モデレーターかどうか
  def moderator?
    get_user_permission_level >= PERMISSION_LEVELS['moderator']
  end

  # 特定のロールを持っているかどうか
  def has_role?(role_name)
    return false unless @server_id

    membership = Membership.find_by(
      server_id: @server_id,
      user_auth0_id: @user_auth0_id
    )
    return false unless membership

    membership.role_assignments
              .joins(:server_role)
              .exists?('LOWER(server_roles.name) = ?', role_name.downcase)
  end

  private

  # サーバーオーナーかどうかチェック
  def server_owner?
    return false unless @server_id && @user_auth0_id
    
    server = Server.find_by(id: @server_id)
    return false unless server
    
    Rails.logger.info "RBAC Debug: Checking owner for user_id=#{@user_auth0_id}, server_id=#{@server_id}, server.created_by=#{server.created_by}"
    is_owner = server.created_by == @user_auth0_id
    Rails.logger.info "RBAC Debug: Is owner? #{is_owner}"
    
    is_owner
  end

  # チャンネル固有の権限レベルを取得
  def get_channel_permission_level(channel_id)
    # 将来的にチャンネル固有の権限を実装する場合
    # 現在は0を返す
    0
  end

  class << self
    # 権限レベル一覧を取得
    def permission_levels
      PERMISSION_LEVELS
    end

    # 権限一覧を取得
    def permissions
      PERMISSIONS
    end

    # 権限の説明を取得
    def permission_description(permission)
      descriptions = {
        'manage_server' => 'サーバー管理（Adminのみ）',
        'manage_channels' => 'チャンネル管理（Moderator以上）',
        'manage_roles' => 'ロール管理（Adminのみ）',
        'invite_users' => 'ユーザー招待（Member以上）',
        'kick_users' => 'ユーザーキック（Moderator以上）',
        'ban_users' => 'ユーザーBAN（Moderator以上）',
        'read_messages' => 'メッセージ読み取り（全員）',
        'send_messages' => 'メッセージ送信（Member以上）',
        'manage_messages' => 'メッセージ管理（Moderator以上）',
        'read_files' => 'ファイル読み取り（全員）',
        'upload_files' => 'ファイルアップロード（Member以上）',
        'manage_files' => 'ファイル管理（Moderator以上）',
        'manage_channel' => 'チャンネル管理（Moderator以上）'
      }
      descriptions[permission] || permission
    end
  end
end
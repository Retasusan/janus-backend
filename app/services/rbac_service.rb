class RbacService
  # 権限レベル定義
  PERMISSION_LEVELS = {
    'guest' => 1,
    'member' => 10,
    'moderator' => 50,
    'admin' => 100
  }.freeze

  # 権限定義
  PERMISSIONS = {
    # サーバー権限
    'manage_server' => 100,
    'manage_channels' => 50,
    'manage_roles' => 80,
    'invite_users' => 30,
    'kick_users' => 60,
    'ban_users' => 70,
    
    # チャンネル権限
    'read_messages' => 1,
    'send_messages' => 5,
    'manage_messages' => 40,
    'read_files' => 1,
    'upload_files' => 10,
    'manage_files' => 30,
    'manage_channel' => 50
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

    # サーバーメンバーシップを取得
    membership = Membership.find_by(
      server_id: @server_id,
      user_auth0_id: @user_auth0_id
    )
    return 0 unless membership

    # ロール割り当てから最大権限レベルを取得
    max_level = membership.role_assignments
                          .joins(:server_role)
                          .maximum('server_roles.permission_level') || 0

    # チャンネル固有の権限があれば考慮
    if channel_id
      channel_level = get_channel_permission_level(channel_id)
      max_level = [max_level, channel_level].max
    end

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
        'manage_server' => 'サーバー管理',
        'manage_channels' => 'チャンネル管理',
        'manage_roles' => 'ロール管理',
        'invite_users' => 'ユーザー招待',
        'kick_users' => 'ユーザーキック',
        'ban_users' => 'ユーザーBAN',
        'read_messages' => 'メッセージ読み取り',
        'send_messages' => 'メッセージ送信',
        'manage_messages' => 'メッセージ管理',
        'read_files' => 'ファイル読み取り',
        'upload_files' => 'ファイルアップロード',
        'manage_files' => 'ファイル管理',
        'manage_channel' => 'チャンネル管理'
      }
      descriptions[permission] || permission
    end
  end
end
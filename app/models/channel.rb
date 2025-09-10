class Channel < ApplicationRecord
  belongs_to :server
  has_many :messages, dependent: :destroy
  has_many :channel_permissions, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1, maximum: 100 }
  validates :channel_type, presence: true, inclusion: { 
    in: %w[text voice calendar file-share project survey whiteboard wiki rbac],
    message: "%{value} is not a valid channel type" 
  }

  # JSON設定のアクセサー
  def settings
    super || {}
  end

  # チャンネルタイプのエイリアス（フロントエンドとの互換性）
  def type
    channel_type
  end

  def type=(value)
    self.channel_type = value
  end
  
  # ユーザーが特定の権限を持っているかチェック
  def user_has_permission?(user_id, permission_type)
    return true if channel_type != 'rbac'  # RBAC以外のチャンネルは従来通り
    
    # ユーザー固有の権限をチェック
    user_permissions = channel_permissions.for_user(user_id).with_permission(permission_type)
    return true if user_permissions.exists?
    
    # ロールベースの権限をチェック
    user_roles = server.role_assignments
                      .joins(:membership)
                      .where(memberships: { user_auth0_id: user_id })
                      .joins(:server_role)
                      .pluck('server_roles.name')
    
    user_roles.each do |role_name|
      role_permissions = channel_permissions.for_role(role_name).with_permission(permission_type)
      return true if role_permissions.exists?
    end
    
    false
  end
  
  # チャンネルの権限設定を取得
  def permission_settings
    {
      user_permissions: channel_permissions.where(target_type: 'user').group_by(&:target_id),
      role_permissions: channel_permissions.where(target_type: 'role').group_by(&:target_id)
    }
  end
end

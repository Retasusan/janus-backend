class ChannelPermission < ApplicationRecord
  belongs_to :channel
  belongs_to :membership, optional: true  # ユーザー固有の権限
  
  # 権限タイプ
  PERMISSION_TYPES = %w[
    read_messages
    send_messages
    manage_messages
    read_files
    upload_files
    manage_files
    manage_channel
    invite_users
  ].freeze

  validates :permission_type, presence: true, inclusion: { in: PERMISSION_TYPES }
  validates :target_type, presence: true, inclusion: { in: %w[role user] }
  validates :target_id, presence: true
  
  # ロールベースかユーザーベースかを判定
  def role_based?
    target_type == 'role'
  end
  
  def user_based?
    target_type == 'user'
  end
  
  # 権限チェック用のスコープ
  scope :for_user, ->(user_id) { where(target_type: 'user', target_id: user_id) }
  scope :for_role, ->(role_name) { where(target_type: 'role', target_id: role_name) }
  scope :with_permission, ->(permission) { where(permission_type: permission) }
end
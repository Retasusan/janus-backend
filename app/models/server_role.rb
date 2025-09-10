class ServerRole < ApplicationRecord
  belongs_to :server
  has_many :role_assignments, dependent: :destroy
  has_many :memberships, through: :role_assignments
  
  # デフォルトロール
  DEFAULT_ROLES = %w[admin moderator member readonly ob guest].freeze
  
  validates :name, presence: true, length: { minimum: 1, maximum: 50 }
  validates :name, uniqueness: { scope: :server_id }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color" }, allow_blank: true
  
  # 権限レベル（数値が高いほど強い権限）
  def permission_level
    case name.downcase
    when 'admin' then 100
    when 'moderator' then 50
    when 'member' then 10
    when 'readonly' then 3  # 読み取り専用（投稿不可）
    when 'ob' then 2        # OB（読み取りのみ、管理権限なし）
    when 'guest' then 1
    else 5
    end
  end
  
  # デフォルトロールかどうか
  def default_role?
    DEFAULT_ROLES.include?(name.downcase)
  end
end
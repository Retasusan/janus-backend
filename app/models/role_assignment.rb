class RoleAssignment < ApplicationRecord
  belongs_to :membership
  belongs_to :server_role
  
  validates :membership_id, uniqueness: { scope: :server_role_id }
  
  # ユーザーが特定のロールを持っているかチェック
  def self.user_has_role?(user_id, server_id, role_name)
    joins(:membership, :server_role)
      .where(memberships: { user_auth0_id: user_id, server_id: server_id })
      .where(server_roles: { name: role_name })
      .exists?
  end
end
class Membership < ApplicationRecord
  belongs_to :server
  has_many :role_assignments, dependent: :destroy
  has_many :server_roles, through: :role_assignments
  
  # ユーザーのロールを取得
  def user_roles
    server_roles.pluck(:name)
  end
  
  # 特定のロールを持っているかチェック
  def has_role?(role_name)
    server_roles.where(name: role_name).exists?
  end
end

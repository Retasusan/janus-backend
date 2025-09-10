class Server < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships, source: :user_auth0_id
  has_many :channels, dependent: :destroy
  has_many :server_roles, dependent: :destroy
  has_many :role_assignments, through: :server_roles

  before_create :generate_invite_code

  # 招待コードでサーバーを検索
  def self.find_by_invite_code(code)
    find_by(invite_code: code)
  end

  # 新しい招待コードを生成
  def regenerate_invite_code!
    update!(invite_code: generate_unique_invite_code)
  end

  private

  def generate_invite_code
    self.invite_code = generate_unique_invite_code
  end

  def generate_unique_invite_code
    loop do
      code = SecureRandom.alphanumeric(8).upcase
      break code unless Server.exists?(invite_code: code)
    end
  end
end

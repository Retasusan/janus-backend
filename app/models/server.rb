class Server < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships, source: :user_auth0_id
  has_many :channels, dependent: :destroy

  before_create :generate_invite_code

  # 招待コードでサーバーを検索
  def self.find_by_invite_code(code)
    find_by(invite_code: code)
  end

  # APIトークンでサーバーを検索
  def self.find_by_api_token(token)
    find_by(api_token: token)
  end

  # 新しい招待コードを生成
  def regenerate_invite_code!
    update!(invite_code: generate_unique_invite_code)
  end

  # 新しいAPIトークンを生成
  def generate_api_token!
    token = generate_unique_api_token
    update!(api_token: token)
    token
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

  def generate_unique_api_token
    loop do
      token = "janus_#{SecureRandom.hex(32)}"
      break token unless Server.exists?(api_token: token)
    end
  end
end

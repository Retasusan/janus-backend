class Channel < ApplicationRecord
  belongs_to :server
  has_many :messages, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1, maximum: 100 }
  validates :channel_type, presence: true, inclusion: { 
    in: %w[text voice calendar file-share project survey whiteboard wiki],
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
end

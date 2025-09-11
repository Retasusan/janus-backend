class Channel < ApplicationRecord
  belongs_to :server
  has_many :messages, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :channel_files, dependent: :destroy
  has_many :forum_threads, dependent: :destroy
  has_many :whiteboards, dependent: :destroy
  has_many :surveys, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :wiki_pages, dependent: :destroy
  has_many :budget_entries, dependent: :destroy
  has_many :inventory_items, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :diary_entries, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1, maximum: 100 }
  VALID_TYPES = %w[text voice forum calendar file-share project survey whiteboard wiki budget inventory photos diary].freeze
  validates :channel_type, presence: true, inclusion: { in: VALID_TYPES, message: "%{value} is not a valid channel type" }

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

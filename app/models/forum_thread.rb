class ForumThread < ApplicationRecord
  belongs_to :channel
  has_many :forum_posts, dependent: :destroy
  validates :title, presence: true
  validates :created_by, presence: true
end

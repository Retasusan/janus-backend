class ForumPost < ApplicationRecord
  belongs_to :forum_thread
  validates :content, presence: true
  validates :created_by, presence: true
end

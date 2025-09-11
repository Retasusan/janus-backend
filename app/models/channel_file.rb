class ChannelFile < ApplicationRecord
  belongs_to :channel
  has_one_attached :file

  validates :uploaded_by, presence: true
end

class Photo < ApplicationRecord
  belongs_to :channel
  has_one_attached :image
  validates :uploaded_by, presence: true
end

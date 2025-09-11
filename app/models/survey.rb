class Survey < ApplicationRecord
  belongs_to :channel
  has_many :survey_options, dependent: :destroy
  has_many :survey_votes, dependent: :destroy
  accepts_nested_attributes_for :survey_options
  validates :question, presence: true
  validates :created_by, presence: true
end

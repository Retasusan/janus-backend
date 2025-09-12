class Task < ApplicationRecord
  belongs_to :channel
  # Avoid enum DSL issues by providing manual scopes/constants
  STATUS_TODO = 0
  STATUS_DONE = 1

  scope :todo, -> { where(status: STATUS_TODO) }
  scope :done, -> { where(status: STATUS_DONE) }
  validates :title, presence: true
  validates :created_by, presence: true
end

class Whiteboard < ApplicationRecord
  belongs_to :channel
  # operations: JSONB with drawing ops or Fabric.js JSON
  validates :operations, presence: true
  validates :updated_by, presence: true
end

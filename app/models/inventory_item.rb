class InventoryItem < ApplicationRecord
  belongs_to :channel
  validates :name, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :updated_by, presence: true
end

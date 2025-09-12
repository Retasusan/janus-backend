class BudgetEntry < ApplicationRecord
  belongs_to :channel
  enum :kind, { income: 0, expense: 1 }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :title, presence: true
  validates :created_by, presence: true
end

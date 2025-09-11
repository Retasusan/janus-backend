class Event < ApplicationRecord
  belongs_to :channel

  validates :title, presence: true
  validates :start_at, presence: true
  validate :end_after_start

  private

  def end_after_start
    return if end_at.blank? || start_at.blank?
    errors.add(:end_at, 'must be after start_at') if end_at < start_at
  end
end

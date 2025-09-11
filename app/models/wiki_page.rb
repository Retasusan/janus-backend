class WikiPage < ApplicationRecord
  belongs_to :channel
  validates :title, presence: true
  validates :content, presence: true
  validates :user_auth0_id, presence: true
  
  before_validation :ensure_slug

  private

  def ensure_slug
    return if slug.present?

    # Try to generate a readable slug from the title. For non-latin titles,
    # parameterize may return an empty string, so fallback to timestamp+rand.
    candidate = title.to_s.parameterize
    if candidate.blank?
      candidate = "p#{Time.now.to_i}-#{SecureRandom.hex(3)}"
    end
    # Ensure uniqueness by appending a short suffix if necessary
    base = candidate[0,200]
    suffix = 0
    new_slug = base
    while self.class.exists?(channel_id: channel_id, slug: new_slug)
      suffix += 1
      new_slug = "#{base}-#{suffix}"
    end
    self.slug = new_slug
  end
end

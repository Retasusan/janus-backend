class UserProfile < ApplicationRecord
  validates :auth0_id, presence: true, uniqueness: true
  validates :display_name, presence: true, length: { maximum: 100 }

  def self.find_or_create_for_auth0_id(auth0_id, default_name: nil)
    find_or_create_by(auth0_id: auth0_id) do |profile|
      profile.display_name = default_name || "User"
    end
  end
end

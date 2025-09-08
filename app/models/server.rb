class Server < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships, source: :user_auth0_id
  has_many :channels, dependent: :destroy
end

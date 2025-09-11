class SurveyVote < ApplicationRecord
  belongs_to :survey
  belongs_to :survey_option
  validates :voter, presence: true
  validates :survey_id, uniqueness: { scope: [:voter] }
end

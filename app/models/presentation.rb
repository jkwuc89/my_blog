class Presentation < ApplicationRecord
  has_many :conference_presentations, dependent: :destroy
  has_many :conferences, through: :conference_presentations

  validates :title, presence: true
  validates :abstract, presence: true
end

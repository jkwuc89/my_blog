class Presentation < ApplicationRecord
  has_many :conference_presentations, dependent: :destroy
  validates :title, presence: true
  validates :abstract, presence: true
end

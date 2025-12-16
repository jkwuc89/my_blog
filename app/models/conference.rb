class Conference < ApplicationRecord
  has_many :conference_presentations, dependent: :destroy
  has_many :presentations, through: :conference_presentations

  validates :title, presence: true
  validates :year, presence: true
  validates :title, uniqueness: { scope: :year, message: "and year combination must be unique" }
end

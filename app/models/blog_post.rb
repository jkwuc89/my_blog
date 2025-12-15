class BlogPost < ApplicationRecord
  validates :title, presence: true
  validates :filename, presence: true, uniqueness: true
  validates :published_at, presence: true

  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Date.current) }
  scope :recent, -> { order(published_at: :desc) }
end

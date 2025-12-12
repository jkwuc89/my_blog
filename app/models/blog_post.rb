class BlogPost < ApplicationRecord
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :content, presence: true

  before_validation :generate_slug, if: -> { slug.blank? && title.present? }

  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :recent, -> { order(published_at: :desc) }

  private

  def generate_slug
    self.slug = title.parameterize
  end
end

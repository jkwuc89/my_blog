class Bio < ApplicationRecord
  self.table_name = "bio"

  validates :name, presence: true
  validates :brief_bio, presence: true
  validates :content, presence: true, on: :update

  # Singleton pattern - ensure only one record exists
  def self.instance
    record = first_or_initialize
    record.save(validate: false) if record.new_record?
    record
  end
end

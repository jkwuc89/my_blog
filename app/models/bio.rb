class Bio < ApplicationRecord
  validates :content, presence: true, on: :update

  # Singleton pattern - ensure only one record exists
  def self.instance
    record = first_or_initialize
    record.save(validate: false) if record.new_record?
    record
  end
end

class ConferencePresentation < ApplicationRecord
  belongs_to :presentation
  belongs_to :conference
end

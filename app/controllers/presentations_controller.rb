class PresentationsController < ApplicationController
  allow_unauthenticated_access

  def index
    @presentations = Presentation.includes(:conferences).order(:title)
  end
end

class PresentationsController < ApplicationController
  allow_unauthenticated_access

  def index
    @presentations = Presentation.includes(:conference_presentations).order(:title)
    @conferences = ConferencePresentation.select(:conference_name).distinct.order(:conference_name).pluck(:conference_name)

    if params[:conference].present?
      @presentations = @presentations.joins(:conference_presentations)
                                     .where(conference_presentations: { conference_name: params[:conference] })
                                     .distinct
    end

    if params[:sort] == "title"
      @presentations = @presentations.order(:title)
    end
  end
end

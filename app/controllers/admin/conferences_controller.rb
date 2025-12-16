module Admin
  class ConferencesController < BaseController
    before_action :set_conference, only: [:show, :edit, :update, :destroy]

    def index
      @conferences = Conference.order(:title, :year)
    end

    def show
    end

    def new
      @conference = Conference.new
    end

    def create
      @conference = Conference.new(conference_params)
      if @conference.save
        redirect_to admin_conference_path(@conference), notice: "Conference created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @conference.update(conference_params)
        redirect_to admin_conference_path(@conference), notice: "Conference updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @conference.destroy
      redirect_to admin_conferences_path, notice: "Conference deleted successfully."
    end

    private

    def set_conference
      @conference = Conference.find(params[:id])
    end

    def conference_params
      params.require(:conference).permit(:title, :year, :link)
    end
  end
end

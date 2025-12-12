module Admin
  class BiosController < BaseController
    def show
      @bio = Bio.instance
    end

    def edit
      @bio = Bio.instance
    end

    def update
      @bio = Bio.instance
      if @bio.update(bio_params)
        redirect_to admin_bio_path, notice: "Bio updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def bio_params
      params.require(:bio).permit(:content, :resume_url)
    end
  end
end

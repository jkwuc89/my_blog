module Admin
  class ContactInfosController < BaseController
    def show
      @contact_info = ContactInfo.instance
    end

    def edit
      @contact_info = ContactInfo.instance
    end

    def update
      @contact_info = ContactInfo.instance
      if @contact_info.update(contact_info_params)
        redirect_to admin_contact_info_path, notice: "Contact info updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def contact_info_params
      params.require(:contact_info).permit(:email, :github_url, :linkedin_url, :twitter_url, :stackoverflow_url, :untapped_username)
    end
  end
end

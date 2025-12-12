class PagesController < ApplicationController
  def about
    @bio = Bio.instance
    @contact_info = ContactInfo.instance
  end
end

class PagesController < ApplicationController
  allow_unauthenticated_access

  def about
    @bio = Bio.instance
    @contact_info = ContactInfo.instance
  end
end

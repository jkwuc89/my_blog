module Admin
  class BaseController < ApplicationController
    before_action :require_authentication
    layout "admin"
  end
end

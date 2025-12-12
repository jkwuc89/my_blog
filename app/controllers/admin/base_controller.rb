module Admin
  class BaseController < ApplicationController
    before_action :require_authentication
  end
end

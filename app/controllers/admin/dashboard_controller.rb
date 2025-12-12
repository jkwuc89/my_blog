module Admin
  class DashboardController < BaseController
    def index
      @blog_posts_count = BlogPost.count
      @presentations_count = Presentation.count
    end
  end
end

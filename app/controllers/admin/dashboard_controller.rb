module Admin
  class DashboardController < BaseController
    def index
      @blog_posts_count = BlogPost.count
      @presentations_count = Presentation.count
      @conferences_count = Conference.count
    end
  end
end

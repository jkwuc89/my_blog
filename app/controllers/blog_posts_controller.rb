class BlogPostsController < ApplicationController
  allow_unauthenticated_access

  def index
    @blog_posts = BlogPost.published.recent
  end

  def show
    @blog_post = BlogPost.find_by!(slug: params[:slug])
  end
end

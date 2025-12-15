class BlogPostsController < ApplicationController
  allow_unauthenticated_access

  def index
    @blog_posts = BlogPost.published.recent
  end

  def show
    filename = params[:filename]
    # If filename doesn't have .md extension, add it
    filename = "#{filename}.md" unless filename.end_with?(".md")

    @blog_post = BlogPost.find_by!(filename: filename)
    @content = BlogPostFileReader.read_content(@blog_post.filename)

    raise ActiveRecord::RecordNotFound if @content.nil?
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError, "Blog post not found"
  end
end

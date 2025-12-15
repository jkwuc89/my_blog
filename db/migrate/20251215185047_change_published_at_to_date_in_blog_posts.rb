class ChangePublishedAtToDateInBlogPosts < ActiveRecord::Migration[8.1]
  def change
    change_column :blog_posts, :published_at, :date
  end
end

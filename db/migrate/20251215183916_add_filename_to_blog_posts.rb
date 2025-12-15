class AddFilenameToBlogPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :blog_posts, :filename, :string
    add_index :blog_posts, :filename, unique: true
    remove_column :blog_posts, :content, :text
    remove_column :blog_posts, :slug, :string
  end
end

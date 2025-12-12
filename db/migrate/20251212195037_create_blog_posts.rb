class CreateBlogPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.string :slug
      t.text :content
      t.datetime :published_at

      t.timestamps
    end
    add_index :blog_posts, :slug, unique: true
  end
end

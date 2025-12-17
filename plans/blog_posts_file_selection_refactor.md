---
name: Blog Posts File Selection Refactor
overview: Refactor blog posts to use file selection from public/blog_posts directory. Update BlogPostFileReader to read from public/blog_posts, add helper method for available files, change admin form to use dropdown, and ensure index/show pages work with selected files.
todos: []
---

# Blog Posts File Selection Refactor

## Overview
Refactor blog posts to work similarly to presentations: admin form shows a dropdown of .md files from `public/blog_posts/`, and the blog posts pages use the selected file for content and excerpts.

## Current State

- Blog posts stored in `blog_posts/` directory at root (per `BlogPostFileReader`)
- User wants files in `public/blog_posts/` (directory already exists with one file)
- Admin form uses text field for `filename` in [`app/views/admin/blog_posts/_form.html.erb`](app/views/admin/blog_posts/_form.html.erb)
- Index page already uses `BlogPostFileReader.excerpt` to get excerpts
- Show page already uses `BlogPostFileReader.read_content` to get content
- Model has `filename`, `title`, and `published_at` fields

## Changes Required

### 1. Update BlogPostFileReader Service

Modify [`app/services/blog_post_file_reader.rb`](app/services/blog_post_file_reader.rb):

- Change `BLOG_POSTS_DIR` from `Rails.root.join("blog_posts")` to `Rails.root.join("public", "blog_posts")`
- This ensures the service reads from the correct directory

### 2. Add Helper Method

Add to [`app/helpers/application_helper.rb`](app/helpers/application_helper.rb):

- Method: `available_blog_post_files`
- Returns array of .md filenames from `public/blog_posts/` directory
- Filters for .md files only
- Returns empty array if directory doesn't exist
- Similar implementation to `available_presentation_files`

### 3. Update Admin Form

Modify [`app/views/admin/blog_posts/_form.html.erb`](app/views/admin/blog_posts/_form.html.erb):

- Replace `text_field :filename` with `select` field
- Use helper method to populate dropdown options
- Include blank option for "No file selected" (allows clearing the selection)
- Store just the filename (e.g., "2016-8-9-HowDoIChooseAPresentationTopic.md") in `filename` field
- Update help text to reflect dropdown selection

### 4. Verify Index and Show Pages

The existing implementation should continue to work:

- [`app/views/blog_posts/index.html.erb`](app/views/blog_posts/index.html.erb) already uses `BlogPostFileReader.excerpt(post.filename)` - no changes needed
- [`app/views/blog_posts/show.html.erb`](app/views/blog_posts/show.html.erb) already uses `BlogPostFileReader.read_content(@blog_post.filename)` - no changes needed
- Both will automatically work once `BlogPostFileReader` points to `public/blog_posts/`

## Implementation Details

### BlogPostFileReader Update
```ruby
BLOG_POSTS_DIR = Rails.root.join("public", "blog_posts")
```

### Helper Method Implementation
```ruby
def available_blog_post_files
  blog_posts_dir = Rails.root.join('public', 'blog_posts')
  return [] unless Dir.exist?(blog_posts_dir)

  Dir.glob(File.join(blog_posts_dir, '*.md'))
    .map { |path| File.basename(path) }
    .sort
end
```

### Form Select Field
```erb
<%= f.label :filename, "Blog Post File", class: "block text-sm font-medium text-gray-700 mb-2" %>
<%= f.select :filename,
    options_for_select([['No file selected', '']] + available_blog_post_files.map { |f| [f, f] },
    blog_post.filename),
    {},
    { class: admin_input_classes } %>
```

## Notes

- The `filename` field will continue to store filenames (no database change needed)
- Existing blog posts in database may need their filenames updated if files were moved
- Files must be in `public/blog_posts/` directory for the system to find them
- The excerpt and content reading functionality already exists and will work automatically once the directory path is updated


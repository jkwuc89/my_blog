# My Blog

A personal blog website built with Rails 8, featuring blog posts, presentations, and an about page with admin interface for content management.

## Purpose

This project is a rebuild of a Jekyll-based blog site, providing a modern Rails application with:
- Blog posts written in Markdown
- Presentations listing with filtering and sorting
- About page with bio and resume link
- Admin interface for managing all content
- Sticky header and footer with social media links

## Technology Stack

- **Framework:** Rails 8.1.1
- **Database:** SQLite3 (development and production)
- **Frontend:** 
  - Tailwind CSS for styling
  - Hotwire (Turbo) for minimal JavaScript interactions
  - Server-rendered HTML views (ERB templates)
- **Markdown:** Kramdown for rendering Markdown content
- **Icons:** Heroicons for social media icons
- **Authentication:** Rails 8 built-in authentication system
- **Deployment:** Kamal or Railway (see deployment section in plan)

## Prerequisites

- Ruby 3.4.7 or compatible version
- Bundler gem
- SQLite3
- Node.js (for Tailwind CSS compilation)

## Local Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd my-blog
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Set up the database:**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Create initial data (optional):**
   ```bash
   rails db:seed
   ```

5. **Start the development server:**
   ```bash
   bin/dev
   ```
   
   This will start both the Rails server and Tailwind CSS watcher.

6. **Access the application:**
   - Public site: http://localhost:3000
   - Admin interface: http://localhost:3000/admin (requires login)

## Creating an Admin User

1. Start the Rails console:
   ```bash
   rails console
   ```

2. Create a user:
   ```ruby
   User.create(email_address: "your-email@example.com", password: "your-password")
   ```

3. You can now log in at http://localhost:3000/session/new

## Development Workflow

- **Run migrations:** `rails db:migrate`
- **Reset database:** `rails db:reset` (drops, creates, migrates, and seeds)
- **View database:** Use SQLite browser or `rails dbconsole`
- **Run tests:** `rails test`

## Project Structure

```
app/
  controllers/
    pages_controller.rb          # About page
    presentations_controller.rb  # Public presentations
    blog_posts_controller.rb    # Public blog
    admin/                       # Admin controllers
  models/
    bio.rb                       # Bio content (singleton)
    contact_info.rb              # Contact info (singleton)
    presentation.rb              # Presentations
    conference_presentation.rb   # Conference associations
    blog_post.rb                 # Blog posts
  views/
    layouts/                     # Header and footer partials
    pages/                       # About page
    presentations/               # Presentations listing
    blog_posts/                  # Blog posts
    admin/                       # Admin interface views
```

## Features

- **Sticky Header:** Fixed header with name, bio tagline, and navigation
- **Sticky Footer:** Fixed footer with social media icon links
- **Blog:** Markdown-based blog posts with automatic slug generation
- **Presentations:** List of presentations with filtering by conference and sorting
- **About Page:** Bio content, resume link, and contact information
- **Admin Interface:** Full CRUD interface for managing all content
- **Markdown Support:** Kramdown for rendering Markdown in blog posts and bio

## License

Private project - All rights reserved

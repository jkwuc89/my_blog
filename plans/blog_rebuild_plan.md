---
name: Blog Rebuild Plan
overview: Rebuild the Jekyll blog as a Rails 8 application with server-rendered HTML, SQLite database (local and production), Tailwind CSS styling matching current site design, and deploy using Kamal or Railway with automatic GitHub deployments. Includes About page with bio and resume GitHub link, Presentations page with sorting/filtering, Blog with Markdown support, footer with social media icons on all pages, and an admin interface for content management.
todos:
  - id: setup-rails
    content: Create Rails 8 application with SQLite and Tailwind CSS, configure basic structure
    status: pending
  - id: create-models
    content: Generate and implement all models (Bio, Presentation, ConferencePresentation, BlogPost, ContactInfo) with migrations
    status: pending
    dependencies:
      - setup-rails
  - id: implement-auth
    content: Implement built-in Rails authentication system for admin access
    status: pending
    dependencies:
      - setup-rails
  - id: build-admin
    content: Create admin dashboard and CRUD interfaces for all models
    status: pending
    dependencies:
      - create-models
      - implement-auth
  - id: build-about-page
    content: Build About page with bio (Markdown), resume GitHub link, and contact info
    status: pending
    dependencies:
      - create-models
  - id: build-presentations-page
    content: Build Presentations page with Turbo-powered sorting and filtering
    status: pending
    dependencies:
      - create-models
  - id: build-blog-pages
    content: Build Blog index and show pages with Markdown rendering
    status: pending
    dependencies:
      - create-models
  - id: add-markdown-preview
    content: Add Markdown preview functionality to admin editors
    status: pending
    dependencies:
      - build-admin
  - id: migrate-content
    content: Create migration script to import existing Jekyll blog posts
    status: pending
    dependencies:
      - build-blog-pages
  - id: styling
    content: Match current Jekyll site styling using Tailwind CSS, implement sticky header and footer with social media icons on all pages
    status: pending
    dependencies:
      - build-about-page
      - build-presentations-page
      - build-blog-pages
  - id: setup-deployment
    content: Configure deployment using Kamal or Railway with SQLite persistent storage and GitHub integration
    status: pending
    dependencies:
      - styling
---

# Blog Rebuild Plan

## Architecture Overview

**Framework:** Rails 8 with Hotwire (Turbo) for minimal JavaScript

- Server-rendered HTML views (no React complexity)
- SQLite database for both development and production
- Tailwind CSS for styling
- Resume stored as GitHub link (versioned in repository)
- Built-in Rails authentication (Rails 8 authentication generator)
- Deploy using Kamal or Railway (see deployment comparison below)

**Key Principles:**

- Minimal dependencies (Rails core + Tailwind + Markdown renderer)
- Server-rendered HTML with Turbo for interactivity
- Simple deployment via GitHub → automatic deploy
- SQLite everywhere for consistency and simplicity

## Data Models

### Core Models

**Bio** (`app/models/bio.rb`)

- `content` (text) - Markdown bio content
- `resume_url` (string) - GitHub link to latest PDF version (e.g., `https://github.com/jkwuc89/my-blog/raw/main/resume.pdf`)
- Single record (singleton pattern)

**Presentation** (`app/models/presentation.rb`)

- `title` (string)
- `abstract` (text)
- `slides_url` (string, optional)
- `github_url` (string, optional)
- `presented_at` (date) - first presentation date
- `conferences` (has_many :conference_presentations)

**ConferencePresentation** (`app/models/conference_presentation.rb`)

- `presentation_id` (references)
- `conference_name` (string)
- `conference_url` (string, optional)
- `presented_at` (date)

**BlogPost** (`app/models/blog_post.rb`)

- `title` (string)
- `slug` (string, unique)
- `content` (text) - Markdown content
- `published_at` (datetime)
- `created_at`, `updated_at`

**ContactInfo** (`app/models/contact_info.rb`)

- `email` (string)
- `github_url` (string)
- `linkedin_url` (string)
- `twitter_url` (string)
- `stackoverflow_url` (string)
- `untapped_username` (string)
- Single record (singleton pattern)

## Page Specifications

### About Me (`/about`)

- Display bio content (rendered Markdown)
- Display resume download link (GitHub raw URL from `bio.resume_url`)
- Display contact information (email, social links)
- Public page, no authentication required

### Presentations (`/presentations`)

- List all presentations with title, abstract, conferences, dates
- Sortable by title (Turbo-powered, no page reload)
- Filterable by conference name (Turbo-powered dropdown)
- Display slides URL and GitHub URL when available
- Public page, no authentication required

### Blog (`/blog` and `/blog/:slug`)

- Index page: List all blog posts (title, published date)
- Show page: Render individual blog post from Markdown
- Public pages, no authentication required

### Admin Dashboard (`/admin`)

- Login-protected (Rails 8 built-in authentication)
- Manage Bio (Markdown editor with preview, resume URL field)
- Manage Contact Info (form with all social links)
- Manage Presentations (CRUD with conference associations)
- Manage Blog Posts (CRUD with Markdown editor and preview)

### Layout Components

**Header:**
- Your name (links to home)
- Brief bio/tagline (e.g., "Software architect, craft beer aficionado and football fan")
- Navigation menu (Blog, Presentations, About Me)
- **Sticky positioning:** Header remains fixed at top of viewport when scrolling content

**Footer:**
- Social media icon links (appears on all pages)
  - Email icon (mailto link)
  - GitHub icon
  - LinkedIn icon
  - Twitter/X icon
  - Stack Overflow icon (if included in current site)
- Icons use Heroicons library
- Footer styling matches current Jekyll site
- **Sticky positioning:** Footer remains fixed at bottom of viewport when scrolling content

**Styling Requirements:**
- Match current Jekyll site's visual design using Tailwind CSS
- Replicate color scheme, typography, spacing, and layout
- Analyze current site's CSS/styling to identify key design patterns
- Use Tailwind utility classes to achieve similar appearance
- **Sticky positioning:** Use Tailwind's `fixed` or `sticky` utilities for header and footer
  - Header: `fixed top-0` or `sticky top-0` to keep it at top during scroll
  - Footer: `fixed bottom-0` or `sticky bottom-0` to keep it at bottom during scroll
  - Ensure main content has appropriate padding to account for fixed header/footer heights

## Technical Implementation

### Frontend

- **Views:** ERB templates in `app/views/`
- **Styling:** Tailwind CSS via `tailwindcss-rails` gem
  - Match current Jekyll site's visual design and styling
  - Use Tailwind utility classes to replicate color scheme, typography, spacing, and layout
- **Markdown:** `kramdown` gem for rendering
- **Interactivity:** Turbo Frames/Streams for sorting/filtering (no custom JS)
- **Layout:** Shared layout with sticky navigation header and sticky footer
  - Header: Fixed at top with name, brief bio, and navigation links
  - Footer: Fixed at bottom with social media icon links
  - Main content area scrolls between header and footer
- **Footer:** Footer component on all pages with icon links for:
  - Email (mailto link)
  - GitHub
  - LinkedIn
  - Twitter/X
  - Stack Overflow (optional, if included in current site)
- **Icons:** Heroicons (via `heroicons` gem) for social media icons in footer
  - Minimal dependency, SVG-based icons
  - Consistent with Tailwind ecosystem

### Backend

- **Database:** SQLite for both development and production
- **File Storage:** Resume PDF stored in GitHub repository, linked via `resume_url` field
- **Authentication:** Rails 8 built-in authentication generator (`rails generate authentication`)
- **Admin:** Custom admin controllers/views (no ActiveAdmin to keep dependencies minimal)

### Deployment Options Comparison

#### Option 1: Kamal Deployment

**Pros:**

- **Full Control:** Deploy to any VPS (DigitalOcean, Linode, Hetzner, etc.) or cloud provider
- **Cost Effective:** Can use very cheap VPS providers ($5-10/month)
- **Consistency:** Same Docker container in dev and production
- **Zero-Downtime:** Built-in zero-downtime deployment support
- **Simple Config:** Single `config/deploy.yml` file for all deployment settings
- **SQLite Friendly:** Easy to configure persistent volumes for SQLite database
- **Version Control:** All deployment config in repository
- **No Vendor Lock-in:** Can move between providers easily

**Cons:**

- **Initial Setup:** Requires VPS/server setup and Docker installation
- **SSL Management:** Need to configure SSL certificates (Let's Encrypt via Traefik)
- **Server Management:** Responsible for server updates, security patches
- **Learning Curve:** Need to understand Docker and Kamal configuration
- **CI/CD Setup:** Need to configure GitHub Actions for auto-deployment
- **Monitoring:** Need to set up monitoring/logging yourself

**Best For:** Developers comfortable with server management, want maximum control and lowest cost

#### Option 2: Railway Deployment

**Pros:**

- **Managed Service:** No server management required
- **Easy Setup:** Very simple initial deployment (just connect GitHub repo)
- **Automatic Deployments:** Built-in GitHub integration, auto-deploys on push
- **SSL Included:** Automatic SSL certificates
- **Monitoring:** Built-in logs and metrics
- **SQLite Support:** Can use persistent volumes for SQLite
- **Free Tier:** $5/month credit (often sufficient for low-traffic sites)

**Cons:**

- **Vendor Lock-in:** Tied to Railway platform
- **Less Control:** Limited customization compared to self-hosted
- **Cost:** Can be more expensive than VPS ($5-20/month depending on usage)
- **SQLite Considerations:** Need to ensure persistent volume is properly configured

**Best For:** Developers who want simplicity and don't mind managed service, prefer not to manage servers

#### Recommendation

For a personal blog with SQLite, **Kamal is recommended** because:

1. Lower long-term cost ($5-10/month VPS vs $5-20/month Railway)
2. SQLite works well with Kamal's persistent volume approach
3. Full control over deployment and configuration
4. No vendor lock-in
5. Good learning experience for deployment skills

However, Railway is a valid choice if you prioritize ease of setup and don't want to manage servers.

### Deployment Configuration (Kamal)

**File:** `config/deploy.yml`

```yaml
service: my-blog
image: my-blog
servers:
  web:
    hosts:
      - your-domain.com
    options:
      volume: /var/lib/my-blog/db:/rails/db
```

**SQLite Persistent Storage:**

- Mount volume to `/rails/db` directory
- SQLite database file stored in persistent volume
- Survives container restarts and deployments

**GitHub Actions:** Configure workflow to run `kamal deploy` on push to main branch

### Deployment Configuration (Railway)

**Setup:**

- Connect GitHub repository
- Configure environment variables
- Add persistent volume for SQLite database
- Set build command and start command
- Automatic deployments on push to main

## File Structure

```
app/
  models/
    bio.rb
    presentation.rb
    conference_presentation.rb
    blog_post.rb
    contact_info.rb
  controllers/
    pages_controller.rb          # About, Home
    presentations_controller.rb  # Public presentations
    blog_posts_controller.rb     # Public blog
    admin/
      dashboard_controller.rb
      bios_controller.rb
      presentations_controller.rb
      blog_posts_controller.rb
      contact_infos_controller.rb
  views/
    layouts/
      application.html.erb
      _header.html.erb
      _footer.html.erb
    pages/about.html.erb
    presentations/index.html.erb
    blog_posts/index.html.erb
    blog_posts/show.html.erb
    admin/... (admin views)
db/
  migrate/ (migrations for all models)
  seeds.rb (optional seed data)
config/
  routes.rb
  deploy.yml (Kamal config, if using Kamal)
resume.pdf (stored in repository root, versioned in Git)
```

## Development Workflow

1. **Local Setup:**

   - `rails new my-blog --database=sqlite3 --css=tailwind`
   - Add gems: `kramdown`, `tailwindcss-rails`, `heroicons`
   - Run `rails generate authentication` (Rails 8 built-in)
   - Run `bin/setup`
   - Run `bin/dev` (Rails server + Tailwind watcher)

2. **Database:**

   - SQLite in development (`db/development.sqlite3`)
   - SQLite in production (with persistent volume)
   - Run migrations: `rails db:migrate`
   - Create database: `rails db:create` (if needed)
   - Seed initial data: `rails db:seed` (optional, for initial bio/contact info)
   - Reset database: `rails db:reset` (drops, creates, migrates, and seeds)
   - View database: Use SQLite browser or `rails dbconsole`
   - Database file location: `db/development.sqlite3` (development), mounted volume in production

3. **Resume Management:**

   - Store `resume.pdf` in repository root
   - Update resume: commit new PDF to repository
   - Admin interface allows updating the GitHub raw URL link
   - Example URL format: `https://github.com/jkwuc89/my-blog/raw/main/resume.pdf`

4. **Content Migration:**

   - Script to import existing Jekyll blog posts from `_posts/` directory
   - Manual entry for presentations and bio content

## Implementation Steps

1. **Rails Setup & Models** (Week 1)

   - Create Rails 8 app with Tailwind
   - Generate models and migrations
   - Set up Rails 8 authentication
   - Create seed data structure

2. **Authentication & Admin** (Week 1-2)

   - Configure built-in Rails authentication
   - Build admin dashboard layout
   - Create admin CRUD interfaces

3. **Public Pages** (Week 2)

   - Build shared layout with sticky header (name, brief bio, navigation) and sticky footer with social icons
   - Implement sticky positioning for header and footer using Tailwind CSS
   - Build About page with bio and resume GitHub link
   - Build Presentations page with Turbo sorting/filtering
   - Build Blog index and show pages

4. **Styling & Polish** (Week 3)

   - Match current Jekyll site's styling using Tailwind CSS
   - Ensure sticky header and footer are properly styled and functional
   - Implement footer with social media icons (email, GitHub, LinkedIn, Twitter/X, Stack Overflow) on all pages
   - Apply Tailwind styling to all pages to match current design
   - Add Markdown preview in admin
   - Migrate existing Jekyll content
   - Add resume.pdf to repository

5. **Deployment** (Week 3-4)

   - Choose deployment option (Kamal recommended)
   - Set up VPS (if Kamal) or Railway project
   - Configure persistent volume for SQLite
   - Set up GitHub Actions for auto-deployment
   - Deploy and test production
   - Set up custom domain and SSL (if Kamal)

## Cost Estimate

**Kamal Option:**

- **VPS:** $5-10/month (DigitalOcean, Linode, Hetzner)
- **Domain:** $10-15/year (optional)
- **GitHub:** Free
- **Total:** ~$5-10/month

**Railway Option:**

- **Railway:** $0-5/month (free tier with $5 credit, may need to pay more for higher usage)
- **GitHub:** Free
- **Total:** $0-10/month

## Dependencies

**Core:**

- Rails 8
- SQLite3 (development and production)
- Tailwind CSS (via `tailwindcss-rails`)

**Minimal Additions:**

- `kramdown` (Markdown rendering)
- `heroicons` (SVG icons for footer social links)

**Deployment (if using Kamal):**

- `kamal` gem
- Docker (on server)

No additional gems needed for:

- Authentication (Rails 8 built-in)
- File storage (resume in GitHub)
- Admin interface (custom simple interface)


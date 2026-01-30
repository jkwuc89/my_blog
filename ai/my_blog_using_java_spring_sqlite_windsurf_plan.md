# My Blog (Rails) -> Java 25.0.1-tem + Gradle 9.3 + Spring Boot 4.0.2 + Thymeleaf + Tailwind + SQLite

This document describes a learning-focused plan to build a parallel Java/Spring implementation of the existing Rails app in this repository.

The goal is to re-familiarize with modern Java and Spring by re-implementing the same product in a separate Spring Boot codebase.

No incremental migration and no automated comparison harness are required.

## Source of truth: current Rails implementation

### Routes (public)
- `GET /` and `GET /blog` -> `BlogPostsController#index`
- `GET /blog_posts/:filename` -> `BlogPostsController#show`
  - Loads a `BlogPost` row by `filename`
  - Reads Markdown content from `public/blog_posts/<filename>.md` (adds `.md` if omitted)
- `GET /about` -> `PagesController#about`
  - Uses singleton `Bio.instance` and `ContactInfo.instance`
- `GET /presentations` -> `PresentationsController#index`
  - `Presentation.includes(:conferences).order(:title)`

### Routes (auth)
- `resource :session`
  - `SessionsController#new`, `#create`, `#destroy`
- `resources :passwords, param: :token`
  - Password reset flow

### Routes (admin)
All admin routes are under `/admin` and require authentication.

- `/admin` -> `Admin::DashboardController#index`
- `/admin/bio` -> singleton edit/update
- `/admin/contact_info` -> singleton edit/update
- `/admin/conferences` -> CRUD
- `/admin/presentations` -> CRUD
- `/admin/blog_posts` -> CRUD

### Auth behavior (Rails 8 built-in)
- `User` uses `has_secure_password` (`bcrypt`)
- A `Session` record is created on login
- A signed permanent cookie `cookies.signed[:session_id]` stores the `Session` id
- `Admin::BaseController` enforces authentication (`before_action :require_authentication`)

### Data model (SQLite)
From `db/schema.rb`:
- `users` (unique `email_address`, `password_digest`)
- `sessions` (`user_id`, `user_agent`, `ip_address`)
- `blog_posts` (`title`, unique `filename`, `published_at` date)
- `presentations` (`title`, `abstract`, `slides_url`, `github_url`)
- `conferences` (`title`, `year`, `link`) with unique `(title, year)`
- join table `conference_presentations` (`conference_id`, `presentation_id`)
- singleton tables:
  - `bio` (`name`, `brief_bio`, `content`)
  - `contact_info` (`email`, `github_url`, `linkedin_url`, `twitter_url`, `untapped_url`)

### Tailwind
Rails uses `tailwindcss-rails` with a dev Procfile:
- `web: bin/rails server`
- `css: bin/rails tailwindcss:watch`

The Spring implementation will use a standard Tailwind build pipeline (recommended: Node + Tailwind CLI).

## Target stack for the Spring implementation

### Toolchain
- Java 25 (25.0.1-tem from SDKMAN)
- Gradle 9.3
- Spring Boot 4.0.2

### Web
- Spring Boot 4.0.2
- Spring MVC
- Thymeleaf templates

### Persistence
- Spring Data JPA (Hibernate)
- SQLite (via JDBC)
- Flyway migrations

### Security
- Spring Security
- Form login
- Anonymous public site
- Admin site requires authentication

### Styling
- Tailwind CSS
- Node-based Tailwind CLI (recommended)

### Markdown
- Java Markdown library (e.g. CommonMark) for rendering blog post files

## Bootstrap steps (CLI)

### Verify toolchain
Java and Gradle are already installed.

```bash
java -version
gradle -v
```

### Generate a Spring Boot project
Create a separate folder for the Spring app (either in a sibling repo or as a sibling directory).

Example (Gradle):

```bash
mkdir my-blog-spring && cd my-blog-spring

curl -L "https://start.spring.io/starter.zip?type=gradle-project&language=java&bootVersion=4.0.2&javaVersion=25&dependencies=web,thymeleaf,data-jpa,validation,security,actuator,flyway" -o app.zip
unzip app.zip
rm app.zip
```

Run:

```bash
./gradlew bootRun
```

## Tailwind setup in the Spring project

Recommended approach: Node + Tailwind CLI.

```bash
npm init -y
npm i -D tailwindcss
npx tailwindcss init
```

Suggested file layout:
- Tailwind input CSS: `src/main/tailwind/input.css`
- Tailwind output CSS: `src/main/resources/static/assets/app.css`

Suggested `package.json` scripts:
- `dev`: run Tailwind in watch mode
- `build`: run Tailwind minified build

Update Tailwind config `content` to scan:
- `src/main/resources/templates/**/*.html`
- `src/main/resources/static/**/*.js`

In Thymeleaf layout templates, include the generated CSS from `/assets/app.css`.

## Database + migrations

### SQLite
Add dependencies:
- SQLite JDBC driver (xerial)
- Hibernate community dialects (for SQLite dialect)

Use Flyway to manage schema.

### Flyway migrations
Create SQL migrations that mirror the Rails tables and constraints:
- `users`
- `sessions`
- `blog_posts`
- `presentations`
- `conferences`
- `conference_presentations`
- `bio`
- `contact_info`

Notes:
- Add unique indexes:
  - `users.email_address`
  - `blog_posts.filename`
  - `(conferences.title, conferences.year)`
- Add foreign keys:
  - `sessions.user_id -> users.id`
  - join table fks

## Domain modeling in Spring

### Entities
- `User`
- `Session`
- `BlogPost`
- `Presentation`
- `Conference`
- `Bio`
- `ContactInfo`

Relationship:
- `Presentation <-> Conference`
  - Implement as `@ManyToMany` with a join table matching `conference_presentations`.
  - Alternatively, implement an explicit join entity to mirror Rails behavior more directly.

Singleton tables:
- Keep as normal entities but ensure there is only one row.
- Provide a service method that returns the existing row or creates one (similar to Rails `.instance`).

## Controllers + pages to implement (feature parity)

### Public
- `/` and `/blog`
  - list published blog posts (published_at <= today)
- `/blog_posts/{filename}`
  - normalize filename to include `.md`
  - load BlogPost by filename
  - read markdown content from disk
  - render markdown to HTML
- `/about`
  - show Bio + ContactInfo
- `/presentations`
  - list presentations with associated conferences

### Admin (auth required)
- `/admin` dashboard counts
- `/admin/blog_posts` CRUD
- `/admin/presentations` CRUD (including selecting conferences)
- `/admin/conferences` CRUD
- `/admin/bio` edit/update singleton
- `/admin/contact_info` edit/update singleton

## Authentication & authorization plan (admin-only)

Use Spring Security form login.

High-level rules:
- Permit anonymous:
  - `/`, `/blog`, `/blog_posts/**`, `/about`, `/presentations`
  - static assets: `/assets/**`, `/css/**`, `/js/**`, `/images/**`
  - login and password reset pages
- Require authentication:
  - `/admin/**`

Password hashing:
- Use BCrypt (maps well to Rails `has_secure_password`).

Suggested learning path:
- Start with a single admin user seeded into SQLite for early progress.
- Then build a proper admin user CRUD or bootstrap admin creation.

## Blog post Markdown storage decision

Rails reads blog post content from:
- `public/blog_posts/<filename>.md`

In Spring, pick one of these:
- Packaged content in the jar: `src/main/resources/blog_posts/`
- External folder on disk (recommended for easy editing): `./public/blog_posts/` or `./blog_posts/`

If using external disk storage, add a configurable base path (e.g. `BLOG_POSTS_DIR`) in application config.

## Suggested implementation order (learning optimized)

1. Spring Boot skeleton (MVC + Thymeleaf + Tailwind + basic layouts)
2. DB + Flyway migrations + JPA entities + repositories
3. Public pages
   - blog list
   - blog show with markdown rendering
   - presentations list
   - about page
4. Admin area (layout + navigation)
5. Spring Security form login restricted to `/admin/**`
6. Admin CRUD for conferences/presentations/blog_posts
7. Bio/contact_info singleton edit screens
8. Password reset flow (optional, but good learning)

## Completion criteria
- Public site pages render correctly and match the Rails feature set.
- Admin area requires login and supports CRUD operations.
- Styling is implemented with Tailwind.
- Persistence works via SQLite with repeatable Flyway migrations.


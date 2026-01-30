# Java Spring Boot Parallel Implementation Plan

## Project Overview

This plan creates a parallel implementation of the Rails blog application using Java 25, Gradle 9.3, and Spring Boot 4.0.2. The application will maintain feature parity with the existing Rails app, including:

- File-based blog posts (Markdown files in `public/blog_posts/`)
- File-based presentations (PowerPoint files in `public/presentations/`)
- Admin interface with CRUD operations
- Session-based authentication
- Bio and ContactInfo singleton models
- Conference-Presentation many-to-many relationships
- Path-based routing: Rails at `https://jkwuc89.com`, Java at `https://jkwuc89.com/java`

## Architecture Overview

**Directory Structure:**
```
/Users/kwedinger/projects/
├── my-blog/              # Rails implementation (existing)
└── my-blog-java/         # Java/Spring Boot implementation (new, sibling directory)
    ├── src/
    │   ├── main/
    │   │   ├── java/com/kwedinger/blog/
    │   │   │   ├── BlogApplication.java
    │   │   │   ├── config/          # Configuration classes
    │   │   │   ├── controller/      # Public and admin controllers
    │   │   │   ├── model/           # JPA entities (Lombok classes)
    │   │   │   ├── repository/      # Spring Data repositories
    │   │   │   ├── service/         # Business logic
    │   │   │   ├── security/        # Spring Security config
    │   │   │   └── dto/             # Data transfer objects
    │   │   ├── resources/
    │   │   │   ├── application.properties
    │   │   │   ├── db/migration/    # Flyway migrations
    │   │   │   └── static/          # Static files (copied from Rails public/)
    │   │   └── templates/           # Thymeleaf templates
    │   └── test/
    ├── .github/
    │   └── workflows/
    │       └── ci.yml               # GitHub Actions CI workflow
    ├── Dockerfile
    ├── config/
    │   └── deploy.yml               # Kamal deployment config
    └── build.gradle
```

**Note:** The Java implementation is a separate repository in its own directory, not nested under the Rails project. Both projects are siblings under `/Users/kwedinger/projects/`.

## Implementation Steps

### 1. Initialize Spring Boot Project

**CLI Steps:**

```bash
# Navigate to projects directory (parent of my-blog)
cd /Users/kwedinger/projects

# Create new directory for Java implementation (sibling to my-blog)
mkdir my-blog-java
cd my-blog-java

# Initialize Spring Boot project using Spring Boot CLI
spring init \
  --dependencies=web,thymeleaf,data-jpa,security \
  --build=gradle \
  --java-version=25 \
  --boot-version=4.0.2 \
  --group-id=com.kwedinger \
  --artifact-id=my-blog-java \
  --package-name=com.kwedinger.blog \
  --name=my-blog-java \
  --description="Personal blog website built with Spring Boot"

# Note: SQLite JDBC driver, Flyway, and Markdown libraries need to be added manually to build.gradle
```

**Post-Initialization Steps:**

- Add SQLite JDBC driver dependency to `build.gradle`
- Add Flyway Core dependency for database migrations
- Add Markdown processing library (CommonMark or Flexmark)
- Add BCrypt for password hashing (usually included with Spring Security)

### 2. Project Structure Setup

Create the following directory structure:

- `src/main/java/com/kwedinger/blog/` - Main Java source
- `src/main/resources/templates/` - Thymeleaf templates
- `src/main/resources/static/` - Static assets (copied from Rails `public/`)
- `src/main/resources/db/migration/` - Flyway migration scripts
- `src/test/java/com/kwedinger/blog/` - Test classes

### 3. Database Configuration

**Files to create:**

- `src/main/resources/application.properties` - Database and app configuration
- `src/main/resources/db/migration/V1__initial_schema.sql` - Initial database schema

**Key configurations:**

- SQLite database path: `storage/java_development.sqlite3` (separate from Rails database)
- Flyway migration enabled
- JPA properties for SQLite compatibility
- Note: Java implementation uses its own database file, separate from the Rails implementation

### 4. Entity Models (JPA) - Using Lombok to Reduce Boilerplate

Create JPA entities using Lombok annotations to eliminate boilerplate code (getters, setters, toString, equals, hashCode) while maintaining mutability required for JPA updates.

**Why Lombok Instead of Records:**

- **Mutability:** JPA entities need to be mutable for in-place updates
- **Proxy Support:** Hibernate can create proxies for lazy loading
- **Standard Pattern:** `@Entity` + `@Data` is the standard approach for JPA entities
- **Less Boilerplate:** Lombok generates getters, setters, toString, equals, hashCode automatically
- **Works Perfectly:** No limitations with relationships, lazy loading, or updates

**Example Lombok Entity Pattern:**

```java
@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "email_address", nullable = false, unique = true)
    private String emailAddress;
    
    @Column(name = "password_digest", nullable = false)
    private String passwordDigest;
    
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Session> sessions = new ArrayList<>();
    
    // Pre-persist hook to set timestamps
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    // Pre-update hook to update timestamp
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
```

**Lombok Annotations Used:**

- `@Data` - Generates getters, setters, toString, equals, hashCode
- `@NoArgsConstructor` - Required by JPA (no-args constructor)
- `@AllArgsConstructor` - Optional, useful for testing/construction
- `@Entity` - JPA entity annotation
- `@Table` - Table mapping
- `@PrePersist` / `@PreUpdate` - Automatic timestamp management

**Entity Classes to Create:**

- **User** (`com.kwedinger.blog.model.User`)
  - Fields: `id`, `emailAddress`, `passwordDigest`, `createdAt`, `updatedAt`
  - OneToMany relationship with Session
  - Use `@OneToMany(mappedBy = "user")`

- **Session** (`com.kwedinger.blog.model.Session`)
  - Fields: `id`, `userId`, `userAgent`, `ipAddress`, `createdAt`, `updatedAt`
  - ManyToOne relationship with User
  - Use `@ManyToOne` with `@JoinColumn(name = "user_id")`

- **Bio** (`com.kwedinger.blog.model.Bio`)
  - Fields: `id`, `name`, `briefBio`, `content`, `createdAt`, `updatedAt`
  - Singleton pattern implementation (use static factory method in service)

- **ContactInfo** (`com.kwedinger.blog.model.ContactInfo`)
  - Fields: `id`, `email`, `githubUrl`, `linkedinUrl`, `twitterUrl`, `untappedUrl`, `createdAt`, `updatedAt`
  - Singleton pattern implementation (use static factory method in service)

- **BlogPost** (`com.kwedinger.blog.model.BlogPost`)
  - Fields: `id`, `title`, `filename` (unique), `publishedAt`, `createdAt`, `updatedAt`
  - Use `@Table(uniqueConstraints = @UniqueConstraint(columnNames = "filename"))`

- **Presentation** (`com.kwedinger.blog.model.Presentation`)
  - Fields: `id`, `title`, `abstract`, `slidesUrl`, `githubUrl`, `createdAt`, `updatedAt`
  - ManyToMany relationship with Conference
  - Use `@ManyToMany` with `@JoinTable`

- **Conference** (`com.kwedinger.blog.model.Conference`)
  - Fields: `id`, `title`, `year`, `link`, `createdAt`, `updatedAt`
  - ManyToMany relationship with Presentation
  - Unique constraint on (title, year) via `@Table(uniqueConstraints = ...)`

- **ConferencePresentation** (`com.kwedinger.blog.model.ConferencePresentation`)
  - Join table entity with `presentationId` and `conferenceId`
  - Use `@ManyToOne` relationships for explicit join table control

**Using Records for DTOs/Projections:**

While entities use Lombok classes, consider using Java Records for:
- **DTOs** (Data Transfer Objects) for API responses
- **Projections** for read-only queries
- **Value objects** that don't need JPA persistence

Example:
```java
// DTO using Record
public record BlogPostSummary(Long id, String title, LocalDate publishedAt) {}

// Projection query
@Query("SELECT new com.kwedinger.blog.dto.BlogPostSummary(b.id, b.title, b.publishedAt) FROM BlogPost b")
List<BlogPostSummary> findAllSummaries();
```

### 5. Repositories (Spring Data JPA)

Create repository interfaces. Repositories work seamlessly with Lombok-based entities:

- `UserRepository` - extends `JpaRepository<User, Long>`
- `SessionRepository` - extends `JpaRepository<Session, Long>`
- `BioRepository` - extends `JpaRepository<Bio, Long>` with custom singleton methods
- `ContactInfoRepository` - extends `JpaRepository<ContactInfo, Long>` with custom singleton methods
- `BlogPostRepository` - extends `JpaRepository<BlogPost, Long>` with custom query methods for published/recent
- `PresentationRepository` - extends `JpaRepository<Presentation, Long>`
- `ConferenceRepository` - extends `JpaRepository<Conference, Long>`
- `ConferencePresentationRepository` - extends `JpaRepository<ConferencePresentation, Long>`

**Custom Query Methods Example:**

```java
public interface BlogPostRepository extends JpaRepository<BlogPost, Long> {
    List<BlogPost> findByPublishedAtIsNotNullAndPublishedAtLessThanEqualOrderByPublishedAtDesc(LocalDate date);
    
    @Query("SELECT b FROM BlogPost b WHERE b.publishedAt IS NOT NULL AND b.publishedAt <= :date ORDER BY b.publishedAt DESC")
    List<BlogPost> findPublishedRecent(@Param("date") LocalDate date);
    
    Optional<BlogPost> findByFilename(String filename);
}
```

**Note:** With Lombok `@Data`, entities are mutable and work perfectly with JPA's `save()` method for both inserts and updates. No special patterns needed.

### 6. Services

Create service classes:

- **BlogPostFileReader** (`com.kwedinger.blog.service.BlogPostFileReader`)
  - `readContent(String filename)` - Reads markdown file from `src/main/resources/static/blog_posts/`
  - `excerpt(String filename, int words)` - Generates excerpt from markdown

- **MarkdownService** (`com.kwedinger.blog.service.MarkdownService`)
  - `renderMarkdown(String content)` - Converts markdown to HTML (using CommonMark or Flexmark)

- **FileService** (`com.kwedinger.blog.service.FileService`)
  - `getAvailableBlogPostFiles()` - Lists `.md` files in `src/main/resources/static/blog_posts/`
  - `getAvailablePresentationFiles()` - Lists `.pptx` files in `src/main/resources/static/presentations/`

- **BioService** (`com.kwedinger.blog.service.BioService`)
  - Singleton pattern implementation for Bio entity

- **ContactInfoService** (`com.kwedinger.blog.service.ContactInfoService`)
  - Singleton pattern implementation for ContactInfo entity

### 7. Security Configuration

**Files to create:**

- `com.kwedinger.blog.security.SecurityConfig` - Spring Security configuration
- `com.kwedinger.blog.security.SessionAuthenticationFilter` - Custom filter for session-based auth
- `com.kwedinger.blog.security.UserDetailsServiceImpl` - UserDetailsService implementation

**Features:**

- Session-based authentication (not JWT)
- Password hashing with BCrypt
- Protected admin routes (`/admin/**`)
- Public routes: `/`, `/blog`, `/blog/**`, `/presentations`, `/about`
- Session management with cookie-based sessions

### 8. Controllers

**Public Controllers:**

- **BlogPostsController** (`com.kwedinger.blog.controller.BlogPostsController`)
  - `GET /` - Index page (blog posts list)
  - `GET /blog` - Blog posts index
  - `GET /blog/{filename}` - Show blog post

- **PresentationsController** (`com.kwedinger.blog.controller.PresentationsController`)
  - `GET /presentations` - List all presentations

- **PagesController** (`com.kwedinger.blog.controller.PagesController`)
  - `GET /about` - About page

- **SessionsController** (`com.kwedinger.blog.controller.SessionsController`)
  - `GET /session/new` - Login page
  - `POST /session` - Create session (login)
  - `DELETE /session` - Destroy session (logout)

**Admin Controllers:**

- **AdminDashboardController** (`com.kwedinger.blog.controller.admin.AdminDashboardController`)
  - `GET /admin` - Admin dashboard

- **AdminBioController** (`com.kwedinger.blog.controller.admin.AdminBioController`)
  - `GET /admin/bio` - Show bio
  - `GET /admin/bio/edit` - Edit bio form
  - `POST /admin/bio` - Update bio

- **AdminContactInfoController** (`com.kwedinger.blog.controller.admin.AdminContactInfoController`)
  - `GET /admin/contact_info` - Show contact info
  - `GET /admin/contact_info/edit` - Edit form
  - `POST /admin/contact_info` - Update contact info

- **AdminBlogPostsController** (`com.kwedinger.blog.controller.admin.AdminBlogPostsController`)
  - Full CRUD: index, show, new, create, edit, update, delete

- **AdminPresentationsController** (`com.kwedinger.blog.controller.admin.AdminPresentationsController`)
  - Full CRUD operations

- **AdminConferencesController** (`com.kwedinger.blog.controller.admin.AdminConferencesController`)
  - Full CRUD operations

### 9. Thymeleaf Templates

Create templates mirroring Rails ERB views:

**Layouts:**

- `templates/layouts/application.html` - Main layout with header/footer
- `templates/layouts/admin.html` - Admin layout

**Partials:**

- `templates/layouts/fragments/header.html` - Sticky header
- `templates/layouts/fragments/footer.html` - Sticky footer with social icons

**Public Views:**

- `templates/blog_posts/index.html` - Blog posts listing
- `templates/blog_posts/show.html` - Individual blog post
- `templates/presentations/index.html` - Presentations listing
- `templates/pages/about.html` - About page
- `templates/sessions/new.html` - Login form

**Admin Views:**

- `templates/admin/dashboard/index.html`
- `templates/admin/bio/show.html`, `edit.html`
- `templates/admin/contact_info/show.html`, `edit.html`
- `templates/admin/blog_posts/index.html`, `show.html`, `new.html`, `edit.html`, `_form.html`
- `templates/admin/presentations/index.html`, `show.html`, `new.html`, `edit.html`, `_form.html`
- `templates/admin/conferences/index.html`, `show.html`, `new.html`, `edit.html`, `_form.html`

### 10. Static Assets

Copy static assets from the Rails project to the Java project's `src/main/resources/static/` directory.

**Copy Static Files:**

```bash
# Create static directory structure
mkdir -p /Users/kwedinger/projects/my-blog-java/src/main/resources/static

# Copy all static assets from Rails project
cp -r /Users/kwedinger/projects/my-blog/public/* /Users/kwedinger/projects/my-blog-java/src/main/resources/static/

# Verify the structure
ls -la /Users/kwedinger/projects/my-blog-java/src/main/resources/static/
```

**Files to copy:**

- `public/blog_posts/*.md` - Blog post markdown files
- `public/presentations/*.pptx` - Presentation files
- `public/documents/*.pdf` - Resume and documents
- SVG icons for social media (from `public/` or `app/assets/images/`)
- Any other static assets (favicons, robots.txt, etc.)

**Directory Structure After Copy:**

```
src/main/resources/static/
├── blog_posts/
│   └── *.md files
├── presentations/
│   └── *.pptx files
├── documents/
│   └── *.pdf files
├── *.svg (social media icons)
└── other static files
```

**Note:** Static assets are copied once during initial setup. If you add new blog posts or presentations to the Rails project, you'll need to copy them to the Java project as well, or set up a sync script/process.

### 11. Tailwind CSS Integration

**Options:**

1. Use Tailwind CLI standalone
2. Use Maven/Gradle plugin for Tailwind
3. Use CDN (not recommended for production)

**Configuration:**

- Create `tailwind.config.js` (can reuse from Rails)
- Configure build process to compile Tailwind CSS
- Output to `src/main/resources/static/css/application.css`

### 12. Helper Classes / Utilities

Create utility classes similar to Rails helpers:

- **ViewHelper** or use Thymeleaf utility objects
- Methods for: `markdownClasses()`, `linkClasses()`, `renderMarkdown()`, `safeUrl()`, etc.

### 13. Application Properties

**Key configurations in `application.properties`:**

```properties
# Server
server.port=8080
# Context path for /java routing (set via environment variable in production)
# server.servlet.context-path=/java

# Database (separate from Rails implementation)
spring.datasource.url=jdbc:sqlite:storage/java_development.sqlite3
spring.datasource.driver-class-name=org.sqlite.JDBC
spring.jpa.database-platform=org.hibernate.community.dialect.SQLiteDialect
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false

# Flyway
spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration

# Thymeleaf
spring.thymeleaf.prefix=classpath:/templates/
spring.thymeleaf.suffix=.html
spring.thymeleaf.cache=false

# Static resources (copied from Rails project to src/main/resources/static/)
spring.web.resources.static-locations=classpath:/static/

# Session
server.servlet.session.cookie.name=session_id
server.servlet.session.cookie.http-only=true
server.servlet.session.cookie.same-site=lax
```

**Note:** The context path (`/java`) is set via environment variable `SERVER_SERVLET_CONTEXT_PATH` in production (Kamal `deploy.yml`). For local development, you can uncomment the `server.servlet.context-path` line or set it via environment variable.

### 14. Testing Setup

- Configure JUnit 5
- Create integration tests for controllers
- Create unit tests for services
- Use Testcontainers or in-memory SQLite for testing

### 15. Build Configuration

**Dependencies added by Spring Boot CLI:**
- Spring Boot Starter Web
- Spring Boot Starter Thymeleaf
- Spring Boot Starter Data JPA
- Spring Boot Starter Security

**Additional dependencies to add manually to `build.gradle`:**

- SQLite JDBC driver (`org.xerial:sqlite-jdbc`)
- Flyway Core (`org.flywaydb:flyway-core`)
- CommonMark (or Flexmark) for Markdown (`org.commonmark:commonmark` or `com.vladsch.flexmark:flexmark-all`)
- BCrypt (usually included with Spring Security, but verify)
- Lombok (required, for reducing boilerplate in entity classes)

**Example `build.gradle` additions:**

```groovy
dependencies {
    // ... Spring Boot starters from spring init ...
    
    // SQLite JDBC driver
    implementation 'org.xerial:sqlite-jdbc:3.44.1.0'
    
    // Flyway for database migrations
    implementation 'org.flywaydb:flyway-core'
    implementation 'org.flywaydb:flyway-database-sqlite'
    
    // Markdown processing
    implementation 'org.commonmark:commonmark:0.21.0'
    
    // Lombok for reducing boilerplate in entity classes
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'
}
```

### 16. Docker Configuration for Kamal Deployment

**Files to create:**

- `Dockerfile` - Multi-stage Docker build for Spring Boot application
- `config/deploy.yml` - Kamal deployment configuration
- `.dockerignore` - Files to exclude from Docker build

**Dockerfile Structure:**

```dockerfile
# syntax=docker/dockerfile:1
# Multi-stage build for Spring Boot application

# Build stage
FROM gradle:9.3-jdk25 AS build
WORKDIR /app
COPY build.gradle settings.gradle ./
COPY gradle ./gradle
COPY src ./src
RUN gradle build --no-daemon -x test

# Runtime stage
FROM eclipse-temurin:25-jre-jammy
WORKDIR /app
RUN groupadd --system --gid 1000 spring && \
    useradd spring --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000
COPY --chown=spring:spring --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**Kamal deploy.yml Configuration:**

```yaml
service: my-blog-java
image: ghcr.io/jkwuc89/my_blog_java

servers:
  web:
    hosts:
      - 209.97.157.86  # DigitalOcean droplet IP
    labels:
      # Path-based routing: Java app serves /java/* paths
      traefik.http.routers.my-blog-java.rule: (Host(`jkwuc89.com`) || Host(`www.jkwuc89.com`)) && PathPrefix(`/java`)
      traefik.http.routers.my-blog-java.entrypoints: websecure
      traefik.http.routers.my-blog-java.tls.certresolver: letsencrypt
      traefik.http.routers.my-blog-java.priority: 10
      # Strip /java prefix before forwarding to app
      traefik.http.middlewares.my-blog-java-stripprefix.stripprefix.prefixes: /java
      traefik.http.routers.my-blog-java.middlewares: my-blog-java-stripprefix
      traefik.http.services.my-blog-java.loadbalancer.server.port: 8080

proxy:
  ssl: true
  hosts:
    - jkwuc89.com
    - www.jkwuc89.com

registry:
  server: ghcr.io
  username: jkwuc89
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - SPRING_DATASOURCE_PASSWORD  # If needed for future DB migration
  clear:
    SPRING_PROFILES_ACTIVE: production
    SPRING_DATASOURCE_URL: "jdbc:sqlite:/app/storage/java_production.sqlite3"
    SERVER_PORT: 8080
    # Configure context path for /java routing
    SERVER_SERVLET_CONTEXT_PATH: /java

volumes:
  - "/var/lib/my-blog-java-storage:/app/storage"

builder:
  arch: amd64
```

**Key Configuration Notes:**

- **Path-based routing:** Java app serves `/java/*` paths, Rails serves root `/`
- **Traefik configuration:**
  - Java router rule: `PathPrefix(/java)` with priority 10
  - Middleware strips `/java` prefix before forwarding to Spring Boot
  - Rails router handles root path (lower priority/default)
- **Spring Boot context path:** Set to `/java` via `SERVER_SERVLET_CONTEXT_PATH`
- **Port:** Java app runs on port 8080 internally
- **Separate volume mount:** Java database (`/var/lib/my-blog-java-storage`)
- **Database path:** `/app/storage/java_production.sqlite3` (inside container)

**Deployment Scripts:**

Create `bin/deploy` script:
```bash
#!/bin/bash
set -a; source .env; set +a; bin/kamal deploy
```

Create `bin/kamal` wrapper (if needed):
```bash
#!/bin/bash
cd "$(dirname "$0")/.."
exec kamal "$@"
```

**Environment Variables (.env):**

Create a `.env` file in the `my-blog-java` directory. The `KAMAL_REGISTRY_PASSWORD` can be reused from the Rails project's `.env` file since both projects use the same GitHub Container Registry:

```bash
# Reuse the same GitHub token from Rails project
KAMAL_REGISTRY_PASSWORD=ghp_your_github_token_here
```

**Note:** You can copy the `KAMAL_REGISTRY_PASSWORD` value directly from `/Users/kwedinger/projects/my-blog/.env` since both projects deploy to the same GitHub Container Registry (ghcr.io).

**Deployment Commands:**

- Initial setup: `set -a; source .env; set +a; bin/kamal setup`
- Deploy updates: `bin/deploy`
- View logs: `bin/kamal app logs -f`
- Access shell: `bin/kamal app exec --interactive --reuse "bash"`
- Run Flyway migrations: `bin/kamal app exec "java -jar app.jar --spring.flyway.migrate=true"`

### 17. GitHub Repository Setup

**Create New GitHub Repository:**

1. **Create repository on GitHub:**
   - Repository name: `my-blog-java` (or preferred name)
   - Description: "Personal blog website built with Spring Boot 4.0.2"
   - Visibility: Private (or public, as preferred)
   - Do NOT initialize with README, .gitignore, or license (Spring Boot CLI creates these)

2. **Initialize Git repository early (after Spring Boot project initialization):**
   ```bash
   cd /Users/kwedinger/projects/my-blog-java
   git init
   git branch -M main
   git remote add origin https://github.com/jkwuc89/my-blog-java.git
   ```
   
   **Note:** Initialize git early (after step 1 of Implementation Todos), but make the initial commit after Spring Boot CLI setup. Then continue with incremental commits as you work through the todos.

3. **Initial commit (after Spring Boot CLI setup):**
   ```bash
   git add .
   git commit -m "Initial commit: Spring Boot project setup with Gradle 9.3 and Java 25"
   git push -u origin main
   ```
   
   **Note:** After the initial push, continue making commits for each todo item as specified in the Implementation Todos section.

4. **Create .env file for deployment:**
   ```bash
   # Copy KAMAL_REGISTRY_PASSWORD from Rails project
   cd /Users/kwedinger/projects/my-blog-java
   # Extract the password from Rails .env and create new .env file
   echo "KAMAL_REGISTRY_PASSWORD=$(grep KAMAL_REGISTRY_PASSWORD ../my-blog/.env | cut -d '=' -f2)" > .env
   # Or manually copy the value from ../my-blog/.env
   ```
   
   **Note:** The `KAMAL_REGISTRY_PASSWORD` can be reused from the Rails project's `.env` file since both projects deploy to the same GitHub Container Registry. The `.env` file should already be in `.gitignore` (created by Spring Boot CLI).

5. **Verify .gitignore includes .env:**
   - Spring Boot CLI should create a `.gitignore`, but verify it includes:
     - `build/` (Gradle build output)
     - `.gradle/` (Gradle cache)
     - `*.log` (log files)
     - `storage/` (SQLite database files - or commit empty directory structure)
     - `.env` (environment variables - contains secrets, do not commit)
     - IDE-specific files (`.idea/`, `.vscode/`, etc.)
   
   **Important:** The `.env` file contains `KAMAL_REGISTRY_PASSWORD` which is a secret. Ensure `.env` is in `.gitignore` and never committed to the repository. You can reuse the same password value from the Rails project's `.env` file (`/Users/kwedinger/projects/my-blog/.env`).

### 18. GitHub Actions CI/CD Workflow

**File to create:** `.github/workflows/ci.yml`

**CI Workflow Configuration:**

Create a GitHub Actions workflow that runs on pull requests and pushes to main, building the application and running all tests.

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up JDK 25
        uses: actions/setup-java@v4
        with:
          java-version: '25'
          distribution: 'temurin'
          cache: 'gradle'

      - name: Grant execute permission for gradlew
        run: chmod +x gradlew

      - name: Build with Gradle
        run: ./gradlew build --no-daemon

      - name: Run tests
        run: ./gradlew test --no-daemon

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: build/test-results/test/
          retention-days: 30

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        if: success()
        with:
          name: build-artifacts
          path: build/libs/*.jar
          retention-days: 7
```

**CI Workflow Features:**

- **Triggers:** Runs on pull requests and pushes to main branch
- **Java Setup:** Uses JDK 25 (Temurin distribution)
- **Gradle Caching:** Caches Gradle dependencies for faster builds
- **Build:** Compiles the application and runs all tests
- **Artifacts:** Uploads test results and build artifacts for inspection
- **No Daemon:** Uses `--no-daemon` flag for CI environments

**Optional Additional Jobs:**

Consider adding these jobs for more comprehensive CI:

```yaml
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up JDK 25
        uses: actions/setup-java@v4
        with:
          java-version: '25'
          distribution: 'temurin'
          cache: 'gradle'
      
      - name: Run Checkstyle (if configured)
        run: ./gradlew checkstyleMain checkstyleTest --no-daemon
      
      # Or use SpotBugs, PMD, etc.

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up JDK 25
        uses: actions/setup-java@v4
        with:
          java-version: '25'
          distribution: 'temurin'
          cache: 'gradle'
      
      - name: Run OWASP Dependency Check (if configured)
        run: ./gradlew dependencyCheckAnalyze --no-daemon
```

### 19. Documentation - README.md

Create a comprehensive README.md file that mirrors the Rails version's README structure, adapted for Java/Spring Boot:

**File to create:** `README.md` in the `my-blog-java/` directory

**Sections to include:**

1. **Title and Description**
   - "My Blog - Java/Spring Boot Implementation"
   - Brief description matching Rails version

2. **Purpose**
   - Same purpose statement as Rails version
   - Note that this is a parallel implementation

3. **Technology Stack**
   - Framework: Spring Boot 4.0.2
   - Language: Java 25
   - Build Tool: Gradle 9.3
   - Database: SQLite3 (separate database file: `storage/java_development.sqlite3`)
   - Frontend: Tailwind CSS, Thymeleaf templates
   - Markdown: CommonMark (or Flexmark)
   - Authentication: Spring Security with session-based auth

4. **Prerequisites**
   - Java 25.0.1-tem (via SDKMAN)
   - Gradle 9.3 (via SDKMAN)
   - Spring Boot CLI (via SDKMAN)
   - SQLite3
   - Node.js (for Tailwind CSS compilation)

5. **Local Setup**
   - Clone repository
   - Build with Gradle
   - Run Flyway migrations
   - Start Spring Boot application
   - Access URLs:
     - Local: `http://localhost:8080/java` (with context path)
     - Production: `https://jkwuc89.com/java`

6. **Creating an Admin User**
   - Instructions for creating user via Spring Boot shell or SQL
   - Login URL

7. **Development Workflow**
   - Running migrations (Flyway)
   - Building the project
   - Running tests
   - Viewing database

8. **Project Structure**
   - Java/Spring Boot directory layout
   - Explanation of key directories (controllers, models, services, etc.)

9. **Features**
   - Same feature list as Rails version
   - Adapted terminology (Thymeleaf instead of ERB, etc.)

10. **Deployment**
    - Kamal deployment to DigitalOcean droplet
    - Docker-based containerization
    - Path-based routing: Rails at root (`/`), Java at `/java`
    - Traefik reverse proxy with path-based routing rules
    - Environment variables and secrets configuration
    - Volume mounts for database persistence
    - SSL certificate management via Let's Encrypt
    - Deployment commands and workflow
    - CloudFlare DNS configuration (no changes needed)

11. **License**
    - Same license statement

**Key adaptations from Rails README:**
- Replace Rails-specific commands (`rails`, `bundle`) with Gradle/Spring Boot equivalents (`./gradlew`, `spring`)
- Update port references from 3000 to 8080 (or configurable)
- Replace ERB references with Thymeleaf
- Replace Rails console with Spring Boot shell or direct SQL
- Update project structure to reflect Java/Spring Boot conventions
- Note that static files (blog posts, presentations) are copied from Rails project to Java project's `src/main/resources/static/`
- Note that Java implementation uses its own separate database (`storage/java_development.sqlite3`)
- Include Kamal deployment section with Docker configuration
- Include deployment commands and environment setup

## Migration Strategy

1. **Database:** Use separate SQLite database files:
   - Rails: `storage/development.sqlite3`
   - Java: `storage/java_development.sqlite3`
   - Both implementations maintain their own independent databases
   - Data can be synchronized manually if needed, or each implementation can be used independently
2. **Static Files:** Copy static assets from Rails project (`public/`) to Java project (`src/main/resources/static/`)
   - Blog posts, presentations, documents, and other static files are copied during initial setup
   - Both implementations maintain their own copies of static assets
   - New files added to Rails project will need to be copied to Java project manually or via sync process
3. **Incremental Development:** Build one feature at a time, starting with authentication, then public pages, then admin interface
4. **Initial Data:** Since databases are separate, initial data (users, blog posts, presentations, etc.) will need to be set up independently for the Java implementation
5. **Repository Structure:** Java implementation is in a separate GitHub repository, independent from the Rails implementation

## Deployment Strategy

### Kamal Deployment to DigitalOcean

The Java implementation uses Kamal for deployment, consistent with the Rails implementation. Both applications run on the same DigitalOcean droplet using path-based routing:

- **Rails:** `https://jkwuc89.com` (root path)
- **Java:** `https://jkwuc89.com/java` (path prefix)

### Routing Configuration

**Traefik Path-Based Routing:**

1. **Rails Application (Root Path):**
   - Serves: `https://jkwuc89.com` and `https://jkwuc89.com/*`
   - Traefik rule: `Host(jkwuc89.com) || Host(www.jkwuc89.com)` (default priority)
   - Port: 80

2. **Java Application (/java Path):**
   - Serves: `https://jkwuc89.com/java` and `https://jkwuc89.com/java/*`
   - Traefik rule: `(Host(jkwuc89.com) || Host(www.jkwuc89.com)) && PathPrefix(/java)`
   - Priority: 10 (higher than default, so it matches first)
   - Middleware: Strips `/java` prefix before forwarding to Spring Boot
   - Spring Boot context path: `/java` (so app generates correct URLs)
   - Port: 8080

**CloudFlare Configuration:**

No changes needed in CloudFlare. The existing DNS configuration is sufficient:
- A Record: `@` → DigitalOcean droplet IP
- A Record: `www` → DigitalOcean droplet IP

Traefik handles the path-based routing internally.

**DigitalOcean Configuration:**

No changes needed. Both applications run on the same droplet.

**Application Configuration:**

- **Rails:** No changes needed - already configured to serve root path
- **Java:** Configured with `SERVER_SERVLET_CONTEXT_PATH=/java` in `deploy.yml`

### Prerequisites for Deployment

1. **DigitalOcean Droplet:** Already set up for Rails deployment
2. **GitHub Container Registry:** Access token for pushing Docker images (reuse from Rails project)
3. **Kamal:** Installed locally (`gem install kamal`)
4. **Docker:** Running locally for building images

### Deployment Steps

1. **Configure Environment:**
   - Create `.env` file in `my-blog-java` directory
   - Copy `KAMAL_REGISTRY_PASSWORD` from Rails project's `.env` file (`/Users/kwedinger/projects/my-blog/.env`)
   - Both projects can use the same GitHub token since they deploy to the same registry
   - Ensure Docker is running locally

2. **Initial Setup:**
   ```bash
   set -a; source .env; set +a; bin/kamal setup
   ```
   This will:
   - Build Docker image locally
   - Push image to GitHub Container Registry
   - Deploy to DigitalOcean droplet
   - Configure Traefik reverse proxy
   - Set up SSL certificates via Let's Encrypt

3. **Routine Deployments:**
   ```bash
   bin/deploy
   ```
   Or manually:
   ```bash
   set -a; source .env; set +a; bin/kamal deploy
   ```

4. **Database Migrations:**
   ```bash
   bin/kamal app exec "java -jar app.jar --spring.flyway.migrate=true"
   ```

### Deployment Configuration Details

- **Image Registry:** GitHub Container Registry (ghcr.io)
- **Container Port:** 8080 (mapped to Traefik)
- **Database Volume:** `/var/lib/my-blog-java-storage` on droplet → `/app/storage` in container
- **Traefik Labels:** Configured for same domains as Rails (jkwuc89.com, www.jkwuc89.com)
- **SSL:** Automatic via Let's Encrypt through Traefik

### Running Both Applications

Both Rails and Java implementations run simultaneously on the same droplet:

- **Routing:**
  - Traefik routes traffic based on URL path
  - Rails: `https://jkwuc89.com` (root)
  - Java: `https://jkwuc89.com/java` (path prefix)
  - Traefik automatically handles SSL certificates for both

- **Infrastructure:**
  - Each app uses its own database volume
  - Each app runs in its own Docker container
  - Traefik reverse proxy handles routing and SSL termination

- **Static Files:**
  - Each app serves its own static assets from its container
  - Java app serves from `src/main/resources/static/` (copied from Rails `public/`)
  - Rails app serves from `public/`

### URL Access

- **Rails version:** `https://jkwuc89.com` (all routes)
- **Java version:** `https://jkwuc89.com/java` (all routes)
  - Example: `https://jkwuc89.com/java/blog`
  - Example: `https://jkwuc89.com/java/admin`
  - Example: `https://jkwuc89.com/java/about`

## CLI Commands Summary

```bash
# 1. Create project directory (sibling to my-blog, not nested)
cd /Users/kwedinger/projects
mkdir my-blog-java && cd my-blog-java

# 2. Initialize Spring Boot project using Spring Boot CLI
spring init \
  --dependencies=web,thymeleaf,data-jpa,security \
  --build=gradle \
  --java-version=25 \
  --boot-version=4.0.2 \
  --group-id=com.kwedinger \
  --artifact-id=my-blog-java \
  --package-name=com.kwedinger.blog \
  --name=my-blog-java \
  --description="Personal blog website built with Spring Boot"

# 3. Add additional dependencies to build.gradle (SQLite, Flyway, Markdown)
# Edit build.gradle and add the dependencies listed in section 15

# 4. Create additional directory structure (some created by spring init)
mkdir -p src/main/java/com/kwedinger/blog/{config,controller/admin,security,dto}
mkdir -p src/main/resources/templates/{layouts/fragments,blog_posts,presentations,pages,sessions,admin/{bio,contact_info,blog_posts,presentations,conferences}}
mkdir -p src/main/resources/db/migration
mkdir -p src/main/resources/static

# 5. Copy static assets from Rails project
cp -r ../my-blog/public/* src/main/resources/static/
mkdir -p .github/workflows

# 5. Copy static assets from Rails project
cp -r ../my-blog/public/* src/main/resources/static/

# 6. Create GitHub Actions CI workflow
# Create .github/workflows/ci.yml (see section 18)

# 7. Initialize Git repository and connect to GitHub
git init
git add .
git commit -m "Initial commit: Spring Boot project setup"
git branch -M main
git remote add origin https://github.com/jkwuc89/my-blog-java.git
git push -u origin main

# 9. Verify versions
java -version     # Should show 25.0.1-tem
gradle -v         # Should show 9.3
spring --version  # Should show Spring Boot CLI version

# 10. After setup, build and run
./gradlew build
./gradlew bootRun
```

## Key Differences from Rails

1. **Templating:** Thymeleaf instead of ERB
2. **Routing:** Spring MVC `@RequestMapping` instead of `routes.rb`
3. **Authentication:** Spring Security instead of Rails built-in auth
4. **Database:** Flyway migrations instead of Rails migrations
5. **Markdown:** CommonMark/Flexmark instead of Kramdown
6. **File Structure:** Maven/Gradle standard layout instead of Rails conventions
7. **Entities:** Lombok-annotated classes instead of ActiveRecord models
8. **Boilerplate Reduction:** Lombok `@Data` generates getters, setters, toString, equals, hashCode automatically

## Next Steps After Implementation

1. Test all public routes
2. Test admin authentication and CRUD operations
3. Verify file-based blog posts and presentations render correctly
4. Ensure Tailwind CSS styling matches Rails version
5. Test session management and security
6. Performance testing and optimization
7. Test Kamal deployment to DigitalOcean droplet
8. Verify path-based routing works correctly

## Implementation Todos

Each todo should be followed by a git commit with a meaningful commit message. Commits should be atomic and focused on a single feature or change.

1. **Initialize Spring Boot project using Spring Boot CLI with Gradle 9.3 and Java 25**
   - **Commit:** `git commit -m "Initial commit: Spring Boot project setup with Gradle 9.3 and Java 25"`

2. **Add additional dependencies to build.gradle (SQLite JDBC driver, Flyway, Markdown library) after spring init**
   - **Commit:** `git commit -m "Add dependencies: SQLite JDBC, Flyway, CommonMark, Lombok"`

3. **Set up application.properties with SQLite database configuration and Flyway migrations**
   - **Commit:** `git commit -m "Configure application.properties for SQLite and Flyway"`

4. **Create Flyway migration script (V1__initial_schema.sql) matching Rails schema**
   - **Commit:** `git commit -m "Add Flyway migration: initial database schema"`

5. **Create JPA entity models using Lombok (User, Session, Bio, ContactInfo, BlogPost, Presentation, Conference, ConferencePresentation)**
   - **Commit:** `git commit -m "Add JPA entity models with Lombok annotations"`

6. **Create Spring Data JPA repositories for all entities**
   - **Commit:** `git commit -m "Add Spring Data JPA repositories for all entities"`

7. **Implement service classes (BlogPostFileReader, MarkdownService, FileService, BioService, ContactInfoService)**
   - **Commit:** `git commit -m "Add service classes for blog posts, markdown, files, and singletons"`

8. **Configure Spring Security with session-based authentication and admin route protection**
   - **Commit:** `git commit -m "Configure Spring Security with session-based authentication"`

9. **Create public controllers (BlogPostsController, PresentationsController, PagesController, SessionsController)**
   - **Commit:** `git commit -m "Add public controllers for blog, presentations, pages, and sessions"`

10. **Create admin controllers (Dashboard, Bio, ContactInfo, BlogPosts, Presentations, Conferences)**
    - **Commit:** `git commit -m "Add admin controllers for dashboard and CRUD operations"`

11. **Create Thymeleaf templates for all public and admin views**
    - **Commit:** `git commit -m "Add Thymeleaf templates for public and admin views"`

12. **Copy static assets from Rails project to Java project's src/main/resources/static/**
    - **Commit:** `git commit -m "Add static assets: blog posts, presentations, and documents"`

13. **Configure Tailwind CSS compilation and integration**
    - **Commit:** `git commit -m "Configure Tailwind CSS compilation and integration"`

14. **Create utility/helper classes for view rendering (markdown, URL safety, CSS classes)**
    - **Commit:** `git commit -m "Add utility classes for view rendering helpers"`

15. **Create Dockerfile for containerized deployment**
    - **Commit:** `git commit -m "Add Dockerfile for containerized deployment"`

16. **Create Kamal deployment configuration (config/deploy.yml)**
    - **Commit:** `git commit -m "Add Kamal deployment configuration"`

17. **Create deployment scripts (bin/deploy, bin/kamal wrapper)**
    - **Commit:** `git commit -m "Add deployment scripts for Kamal"`

18. **Create new GitHub repository for Java implementation**
    - **Note:** This is done on GitHub, not in code. No commit needed.

19. **Create GitHub Actions CI workflow (.github/workflows/ci.yml) for automated testing**
    - **Commit:** `git commit -m "Add GitHub Actions CI workflow for automated testing"`

20. **Initialize Git repository and push to GitHub**
    - **Note:** This happens after the first commit. Subsequent commits are pushed as work progresses.

21. **Create README.md documenting the Java/Spring Boot implementation**
    - **Commit:** `git commit -m "Add README.md with setup and deployment documentation"`

22. **Test authentication flow and session management**
    - **Commit (if fixes needed):** `git commit -m "Fix authentication flow and session management"`

23. **Test all CRUD operations in admin interface**
    - **Commit (if fixes needed):** `git commit -m "Fix admin CRUD operations"`

24. **Verify file-based blog posts and presentations render correctly**
    - **Commit (if fixes needed):** `git commit -m "Fix static file serving and rendering"`

25. **Test Kamal deployment to DigitalOcean droplet**
    - **Commit (if fixes needed):** `git commit -m "Fix deployment configuration"`

26. **Verify CI workflow runs successfully on GitHub**
    - **Commit (if fixes needed):** `git commit -m "Fix CI workflow configuration"`

**Git Workflow Notes:**

- Initialize git repository early (after step 1 or 2) with `git init`
- Make commits after each logical unit of work
- Push to GitHub after step 20 (initial push) and periodically as work progresses
- Use descriptive commit messages following conventional commit format
- Group related small changes together when it makes sense (e.g., multiple entity models in one commit)
- Test before committing when possible

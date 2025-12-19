# Deployment Guide: Rails 8 to DigitalOcean

This guide covers the deployment of the `my_blog` application to a DigitalOcean Basic Droplet using Kamal 2.
It is configured for a SQLite database, Tailwind CSS, and supports both `yourdomain.com` and `www.yourdomain.com`.

## Prerequisites

1. **DigitalOcean Account:** [Create an account](https://cloud.digitalocean.com/).
2. **Domain Name:** Registered (instructions below).
3. **GitHub Container Registry (GHCR) Access:** We will store your Docker images on GitHub.

---

## Step 1: Server Setup (DigitalOcean)
1. **Create a Droplet:**
   * **Region:** **New York (NYC3)** (Closest to Ohio).
   * **Image:** **Ubuntu 24.04 (LTS) x64**.
   * **Size:** Choose **Basic** -> **Regular** (Disk type: SSD).
   * **CPU Options:** Select the **$6/month** option (1GB RAM / 1 CPU).
   * *Warning:* Do not choose the $4 (512MB) option. Rails + Docker usually requires at least 1GB of RAM to run stable.
   * **Authentication Method:** Select **SSH Key** and add your local machine's public key (e.g., `~/.ssh/id_ed25519.pub`).

2. **Note the IP Address:** Once the Droplet is created, copy the **ipv4 address** (e.g., `192.0.2.1`).

## Step 2: DNS Configuration

Go to your domain registrar (Porkbun, Cloudflare, Namecheap, etc.) and create **two** records to ensure users can reach you whether they type `www` or not.

| Type | Host | Value | TTL |
| --- | --- | --- | --- |
| **A Record** | `@` (root) | `[Your DigitalOcean IP]` | Automatic/600s |
| **A Record** | `www` | `[Your DigitalOcean IP]` | Automatic/600s |

## Step 3: Configure Kamal

Ensure Kamal is installed locally:

```bash
gem install kamal
kamal init
```

Replace the contents of your generated `deploy.yml` with the configuration below.
This includes the logic for SQLite persistence and the `www` subdomain routing.

```yaml
# config/deploy.yml
service: my-blog
image: ghcr.io/jkwuc89/my_blog

servers:
  web:
    hosts:
      - 192.0.2.1  # <--- REPLACE with your DigitalOcean IP address
    labels:
      # This rule tells Traefik to accept traffic for both the root domain and www
      traefik.http.routers.my-blog.rule: Host(`yourdomain.com`) || Host(`www.yourdomain.com`)
      traefik.http.routers.my-blog.entrypoints: websecure
      traefik.http.routers.my-blog.tls.certresolver: letsencrypt

# Docker Registry Configuration (GitHub Container Registry)
registry:
  server: ghcr.io
  username: jkwuc89
  password:
    - KAMAL_REGISTRY_PASSWORD

# Environment Variables
env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    # Set to production to ensure Rails 8 config defaults are used
    RAILS_ENV: production
    # Ensure the container knows where the DB is expected
    DATABASE_URL: "sqlite3:///rails/storage/production.sqlite3"

# CRITICAL: Persist SQLite Database
# This maps a folder on the Droplet to the storage folder in the container.
volumes:
  - "/var/lib/my-blog-storage:/rails/storage"

# Asset bridging (Kamal 2 default)
asset_path: /rails/public/assets

# Build architecture
# You are on an M3 Max (ARM), but the Basic Droplet is likely Intel (AMD64).
# This tells Docker to build for the server's architecture, not your laptop's.
builder:
  arch: amd64

```

## Step 4: Secrets & Environment

You need to provide Kamal with your Registry password (GitHub Token) and your Rails Master Key.

1. **Get a GitHub Personal Access Token:**
   * Go to GitHub Settings -> Developer Settings -> Personal access tokens (Classic).
   * Generate new token -> Select scopes: `write:packages`, `delete:packages`, `repo`.
   * Copy the token.

2. **Configure `.env`:**
   Create (or update) a `.env` file in your project root. **Do not commit this file to Git.**
   ```bash
   KAMAL_REGISTRY_PASSWORD=ghp_your_github_token_here
   RAILS_MASTER_KEY=your_master_key_from_config_master_key
   ```

## Step 5: Initial Deployment

Run the setup command. This will:

1. Load the environment variables from `.env`.
1. Install Docker on the Droplet.
1. Push your environment variables.
1. Build your app locally (including Tailwind CSS compilation).
1. Push the image to GHCR.
1. Start Traefik (proxy) and your App on the server.
1. Issue SSL certificates automatically for both domains.

```bash
set -a; source .env; set +a; bin/kamal setup
```

**Troubleshooting SQLite:**

If the database isn't created automatically, you can trigger the creation manually after the first deploy:

```bash
set -a; source .env; set +a; bin/kamal app exec -- "bin/rails db:prepare"
```

## Routine Deployments

For future updates (code changes, CSS updates), simply run:

```bash
set -a; source .env; set +a; bin/kamal deploy
```

Because of the `volumes` configuration in `deploy.yml`, your `production.sqlite3`
file will persist in `/var/lib/my-blog-storage` on the Droplet even as the containers are destroyed and replaced.

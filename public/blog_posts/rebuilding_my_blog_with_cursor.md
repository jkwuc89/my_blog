I finally got around to rebuilding my personal site, [jkwuc89.com](https://jkwuc89.com). For years, this project sat on the back burner—I wanted a modern tech stack, but the thought of writing all the boilerplate code by hand was daunting.

This time, I took a different approach. I used **Cursor**, an AI-powered code editor, to build a full Ruby on Rails 8 application from scratch and deploy it to a DigitalOcean droplet.

What normally would have taken me weeks of evenings and weekends took just a few days. Here is a look at how I built it, the stack I chose, and how AI changed my development workflow.

## The "Architect" Workflow

The biggest shift in this project was my role. I spent almost no time typing code character-by-character. Instead, I operated as the architect and code reviewer, while Cursor acted as the implementation team.

I leaned heavily on **Cursor’s Composer Mode** to build features. Instead of manually creating controllers and views, I would write prompts like:

> *"Create an admin interface that allows full CRUD operations for blog posts and presentations. Include a dropdown to select from available Markdown files in the public directory."*

Cursor would generate the models, controllers, and views. My job was simply to review the logic, test it, and approve the changes.

When I ran into UI glitches—like a footer that refused to stay at the bottom or mobile responsiveness issues—I used **Cursor’s AI Agent**. I could simply point it at a file and say *"Fix the sticky footer so it stays at the bottom on mobile,"* and it would analyze the Tailwind classes and apply the fix automatically.

## The Stack: Rails 8 & SQLite

I wanted this blog to be low-maintenance but high-performance. Rails 8 was the obvious choice because of its "One Person Framework" philosophy.

* **Framework:** Rails 8.1.1
* **Database:** SQLite3 for both development and production. Rails 8 has made SQLite a viable production database.
* **Frontend:** Tailwind CSS for styling and Hotwire (Turbo) for minimal JavaScript interactions.
* **Content:** I kept the content management file-based. Blog posts are Markdown files rendered via Kramdown, and presentations are stored as slide decks.

## Features Built with AI

Using Cursor, I was able to implement a surprising amount of functionality in a short sprint:

1. **Custom Admin Interface:** A secure backend to manage bio content, contact info, and blog posts.
1. **Smart Content Loading:** The app automatically reads Markdown files from `public/blog_posts/` and auto-generates excerpts.
1. **Sticky UI:** A responsive layout with a fixed header (featuring my profile photo and bio) and a sticky footer with SVG social icons that highlight on hover.
1. **GitHub Integration:** The presentations page automatically links to relevant GitHub repositories alongside slide deck downloads.

## Deployment: Kamal 2 & DigitalOcean

Deploying Rails apps used to be a headache unless you paid a premium for a PaaS. With Rails 8, **Kamal 2** is the default deployment tool, and it is a game changer.

I deployed the app to a basic **$6/month DigitalOcean Droplet** in the NYC3 region.

### How it works

Kamal containerizes the application using Docker. It handles everything from setting up the server to obtaining SSL certificates automatically via Let’s Encrypt.

The most critical part of the configuration was handling the SQLite database. Since Docker containers are ephemeral, I had to configure persistent volumes in my `deploy.yml`.

```yaml
# config/deploy.yml
volumes:
  - "/var/lib/my-blog-storage:/rails/storage"
```

This maps a folder on the DigitalOcean server directly to the Rails storage folder, ensuring my production database survives between deployments.

## Conclusion

Rebuilding https://jkwuc89.com proved to me that the barrier to entry for building robust, custom software has never been lower. By combining the conventions of Rails 8 with the speed of Cursor AI, one developer can now do the work of a small team.

If you are interested in the code, you can check out the full implementation on GitHub: https://github.com/jkwuc89/my_blog

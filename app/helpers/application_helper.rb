module ApplicationHelper
  def admin_input_classes
    "block w-full bg-white border border-gray-200 rounded-md px-4 py-3 focus:border-blue-500 transition-all"
  end

  def contact_info
    @contact_info ||= ContactInfo.instance
  end

  def h1_classes
    "text-2xl font-bold mb-3"
  end

  def link_classes
    "text-blue-500 hover:underline"
  end

  def render_markdown(content)
    return "" if content.blank?
    html = Kramdown::Document.new(content).to_html

    # Insert spacing divs between paragraphs that were separated by blank lines
    # This preserves the visual spacing of blank lines in the original markdown
    html.gsub(/<\/p>\s*(?=<p>)/, "</p><div class='h-4'></div>").html_safe
  end

  def safe_url(url)
    return nil if url.blank?
    return url if url.start_with?("http://", "https://")
    nil
  end

  def available_presentation_files
    presentations_dir = Rails.root.join("public", "presentations")
    return [] unless Dir.exist?(presentations_dir)

    Dir.glob(File.join(presentations_dir, "*.pptx"))
      .map { |path| File.basename(path) }
      .sort
  end

  def available_blog_post_files
    blog_posts_dir = Rails.root.join("public", "blog_posts")
    return [] unless Dir.exist?(blog_posts_dir)

    Dir.glob(File.join(blog_posts_dir, "*.md"))
      .map { |path| File.basename(path) }
      .sort
  end
end

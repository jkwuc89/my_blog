module ApplicationHelper
  def admin_input_classes
    "block w-full bg-white border border-gray-200 rounded-md px-4 py-3 focus:border-blue-500 transition-all"
  end

  def available_blog_post_files
    blog_posts_dir = Rails.root.join("public", "blog_posts")
    return [] unless Dir.exist?(blog_posts_dir)

    Dir.glob(File.join(blog_posts_dir, "*.md"))
      .map { |path| File.basename(path) }
      .sort
  end

  def available_presentation_files
    presentations_dir = Rails.root.join("public", "presentations")
    return [] unless Dir.exist?(presentations_dir)

    Dir.glob(File.join(presentations_dir, "*.pptx"))
      .map { |path| File.basename(path) }
      .sort
  end

  def contact_info
    @contact_info ||= ContactInfo.instance
  end

  def footer_icon_hover_classes
    "hover:ring-2 hover:ring-blue-500 hover:ring-offset-2 rounded transition-all duration-200"
  end

  def h1_classes
    "text-2xl font-bold mb-3"
  end

  def link_classes
    "text-blue-500 hover:underline"
  end

  def markdown_classes
    "max-w-none [&>p+p]:mt-6 [&_a]:text-blue-500 [&_a]:hover:underline [&_h1]:text-3xl [&_h1]:font-bold [&_h1]:mt-8 [&_h1]:mb-4 [&_h2]:text-2xl [&_h2]:font-bold [&_h2]:mt-6 [&_h2]:mb-3 [&_h3]:text-xl [&_h3]:font-semibold [&_h3]:mt-5 [&_h3]:mb-2 [&_h4]:text-lg [&_h4]:font-semibold [&_h4]:mt-4 [&_h4]:mb-2 [&_h5]:text-base [&_h5]:font-semibold [&_h5]:mt-3 [&_h5]:mb-2 [&_h6]:text-sm [&_h6]:font-semibold [&_h6]:mt-2 [&_h6]:mb-2 [&_ul]:list-disc [&_ul]:list-inside [&_ul]:my-4 [&_ul]:space-y-2 [&_ol]:list-decimal [&_ol]:list-inside [&_ol]:my-4 [&_ol]:space-y-2 [&_li]:ml-4 [&_code]:bg-gray-100 [&_code]:px-1 [&_code]:py-0.5 [&_code]:rounded [&_code]:text-sm [&_code]:font-mono [&_pre]:bg-gray-100 [&_pre]:p-4 [&_pre]:rounded [&_pre]:overflow-x-auto [&_pre]:my-4 [&_pre_code]:bg-transparent [&_pre_code]:p-0 [&_blockquote]:border-l-4 [&_blockquote]:border-gray-300 [&_blockquote]:pl-4 [&_blockquote]:italic [&_blockquote]:my-4 [&_strong]:font-bold [&_em]:italic"
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
end

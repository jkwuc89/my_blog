module ApplicationHelper
  def contact_info
    @contact_info ||= ContactInfo.instance
  end

  def render_markdown(content)
    return "" if content.blank?
    html = Kramdown::Document.new(content).to_html

    # Insert spacing divs between paragraphs that were separated by blank lines
    # This preserves the visual spacing of blank lines in the original markdown
    html.gsub(/<\/p>\s*(?=<p>)/, '</p><div class="h-4"></div>').html_safe
  end

  def safe_url(url)
    return nil if url.blank?
    return url if url.start_with?("http://", "https://")
    nil
  end

  def admin_input_classes
    "block w-full bg-white border border-gray-200 rounded-md px-4 py-3 focus:border-blue-500 transition-all"
  end
end

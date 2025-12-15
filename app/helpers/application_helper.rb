module ApplicationHelper
  def contact_info
    @contact_info ||= ContactInfo.instance
  end

  def render_markdown(content)
    return "" if content.blank?
    Kramdown::Document.new(content).to_html.html_safe
  end

  def safe_url(url)
    return nil if url.blank?
    return url if url.start_with?("http://", "https://")
    nil
  end
end

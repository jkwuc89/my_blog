module ApplicationHelper
  def contact_info
    @contact_info ||= ContactInfo.instance
  end

  def render_markdown(content)
    return "" if content.blank?
    Kramdown::Document.new(content).to_html.html_safe
  end
end

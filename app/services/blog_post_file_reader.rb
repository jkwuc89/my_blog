class BlogPostFileReader
  BLOG_POSTS_DIR = Rails.root.join("blog_posts")

  def self.read_content(filename)
    file_path = BLOG_POSTS_DIR.join(filename)
    return nil unless File.exist?(file_path)

    File.read(file_path)
  rescue StandardError => e
    Rails.logger.error("Error reading blog post file #{filename}: #{e.message}")
    nil
  end

  def self.excerpt(filename, words: 50)
    content = read_content(filename)
    return "" if content.blank?

    # Remove markdown headers and code blocks for excerpt
    text = content.gsub(/^#+\s+/, "") # Remove headers
      .gsub(/^#+\s+/, "") # Remove headers
      .gsub(/```[\s\S]*?```/, "") # Remove code blocks
      .gsub(/`[^`]+`/, "") # Remove inline code
      .gsub(/\*\*([^\*]+)\*\*/, '\1') # Remove bold (**text**)
      .gsub(/\*([^\*]+)\*/, '\1') # Remove italic (*text*)
      .gsub(/\[([^\]]+)\]\([^\)]+\)/, '\1') # Convert links to text
      .gsub(/[!\[][^\]]*\]\([^\)]+\)/, "") # Remove images
      .strip

    # Split into words and take first N words
    word_array = text.split(/\s+/)
    excerpt_words = word_array.first(words)

    if word_array.length > words
      excerpt_words.join(" ") + "..."
    else
      excerpt_words.join(" ")
    end
  end
end

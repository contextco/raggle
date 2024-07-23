module ApplicationHelper
  def markdown_to_html(markdown)
    renderer = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(filter_html: true),
      autolink: true,
      tables: true,
      fenced_code_blocks: true
    )
    renderer.render(markdown || '')
  end
end

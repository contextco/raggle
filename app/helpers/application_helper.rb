# frozen_string_literal: true

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

  def profile_picture_tag
    image_tag current_user.profile_picture_url,
              class: 'overflow-hidden size-full',
              referrerpolicy: 'no-referrer'
  end

  def delimited_pluralized(number, word)
    "#{number_with_delimiter(number)} #{word.pluralize(number)}"
  end
end

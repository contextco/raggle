# frozen_string_literal: true

class Prompt
  def initialize(name)
    @template = Rails.root.join('app', 'prompts', 'templates', "#{name}.txt.erb")
  end

  def render_to_string(**vars)
    ERB.new(File.read(@template)).result_with_hash(vars)
  end
end

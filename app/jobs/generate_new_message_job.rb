# frozen_string_literal: true

class GenerateNewMessageJob < ApplicationJob
  queue_as :default
  include ActionView::RecordIdentifier
  include ApplicationHelper

  def perform(input_message, output_message)
    generate_new_message(input_message, output_message)
  end

  private

  def generate_new_message(input_message, output_message)
    outcome = llm_client(input_message.chat.model).chat_streaming(
      [
        *prior_messages(output_message.chat, output_message)
      ],
      stream_new_messages(output_message),
      ->(_finish_reason, content) { output_message.update!(content:) }
    )

    raise StandardError, outcome.full_json unless outcome.success
  end

  def stream_new_messages(message)
    lambda { |_new_content, buffer|
      message.broadcast_action(
        :update_and_scroll_to_bottom,
        target: dom_id(message),
        html: markdown_to_html(buffer)
      )
    }
  end

  def prior_messages(chat, current_message)
    chat.messages.excluding(current_message).flat_map do |message|
      buf = message.files.map do |file|
        {
          role: :system,
          content: <<~FILE
            The user uploaded the following file, use this to inform your response if necessary.

            Filename: #{file.filename}

            Contents:
            #{file.download}
          FILE
        }
      end
      buf << { role: message.role, content: message.content }
    end
  end

  def llm_client(model)
    @llm_client = LLM.from_string!(model).client
  end
end

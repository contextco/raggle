class GenerateNewMessageJob < ApplicationJob
  queue_as :default
  include ActionView::RecordIdentifier
  include ApplicationHelper

  def perform(message, content)
    generate_new_message(message, content)
  end

  private

  def generate_new_message(message, content)
    outcome = llm_client(message).chat_streaming(
      [
        *prior_messages(message.chat, message),
        {
          role: :user,
          content: content || ''
        }
      ],
      stream_new_messages(message),
      ->(content) { message.update!(content:) }
    )

    raise StandardError, outcome.full_json unless outcome.success
  end

  def stream_new_messages(message)
    lambda { |buffer|
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
      buf << { role: :assistant, content: message.content }
    end
  end

  def llm_client(message)
    @llm_client = LLM.from_string!(message.chat.model).client
  end
end

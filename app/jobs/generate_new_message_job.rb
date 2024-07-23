class GenerateNewMessageJob < ApplicationJob
  queue_as :default
  include ActionView::RecordIdentifier
  include ApplicationHelper

  def perform(message, content)
    generate_new_message(message, content)
  end

  private

  def generate_new_message(message, content)
    llm_client.chat_streaming(
      [
        *prior_messages(message),
        {
          role: :user,
          content:
        }
      ],
      stream_new_messages(message),
      ->(content) { message.update!(content:) }
    )
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

  def prior_messages(message)
    message.chat.messages - [message]
  end

  def llm_client
    @llm_client = LLM.from_string!('gpt-4o-mini').client
  end
end

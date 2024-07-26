# frozen_string_literal: true

module LLM
  class MessageWindow
    attr_accessor :messages

    def initialize(messages)
      messages ||= []
      @messages = messages.map do |m|
        m.is_a?(LLM::Message) ? m : LLM::Message.new(role: m['role'], message: m['message'])
      end
    end

    def last_user_message
      messages.reverse.find(&:user?)
    end

    def last_user_message_index
      messages.rindex(&:user?)
    end

    def without_last_user_message
      idx = last_user_message_index
      new_messages = messages.select.with_index { |_, index| index != idx }
      LLM::MessageWindow.new(new_messages)
    end

    def [](index)
      return messages[index] if index.is_a?(Integer)

      LLM::MessageWindow.new(messages[index])
    end

    delegate :map, to: :messages
  end
end

# frozen_string_literal: true

class ChatsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_chat, only: %i[show update]
  before_action :load_chats_layout
  def index
    @chat = current_user.chats.build
  end

  def create
    @chat = current_user.chats.create(chat_params.reverse_merge(model: 'gpt-4o-mini'))

    push_chat_forward

    redirect_to chat_path(@chat)
  end

  def update
    push_chat_forward

    redirect_to chat_path(@chat)
  end

  def show; end

  private

  def load_chats_layout
    @chats = current_user.chats.preload(:first_message).limit(20).order(created_at: :desc)
  end

  def message_params
    params.require(:chat).permit(:content)
  end

  def chat_params
    params.require(:chat).permit(:model)
  end

  def set_chat
    @chat = current_user.chats.preload(:messages).find_by(id: params[:id])
    redirect_to chats_path unless @chat
  end

  def push_chat_forward
    input_message, output_message = @chat.transaction do
      input = @chat.messages.create!(message_params.merge(role: :user))
      input.attach(params[:chat][:files]) if params[:chat][:files].present?
      output = @chat.messages.create!(role: :assistant)
      [input, output]
    end
    GenerateNewMessageJob.perform_later(input_message, output_message)
  end
end

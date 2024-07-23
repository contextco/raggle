class ChatsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_chat, only: %i[show update]
  before_action :load_chats_layout
  def index
    @chat = Chat.new
  end

  def create
    @chat = Chat.create!

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
    @chats = Chat.all.limit(20).order(created_at: :desc)
  end

  def chat_params
    params.require(:chat).permit(:content)
  end

  def set_chat
    @chat = Chat.find_by(id: params[:id])
    redirect_to chats_path unless @chat
  end

  def push_chat_forward
    message = @chat.transaction do
      @chat.messages.create!(chat_params.merge(role: :user))
      @chat.messages.create!(role: :assistant)
    end
    GenerateNewMessageJob.perform_later(message, chat_params[:content])
  end
end

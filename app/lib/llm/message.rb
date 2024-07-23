# frozen_string_literal: true

class LLM::Message
  include ActiveModel::API
  attr_accessor :message
  attr_reader :role

  ROLES = %i[assistant user system].freeze

  def role=(value)
    raise ArgumentError, "Invalid role #{value}" unless ROLES.include?(value&.to_sym)

    @role = value.to_sym
  end

  def user?
    role == :user
  end

  def system?
    role == :system
  end

  def assistant?
    role == :assistant
  end

  delegate :blank?, to: :message
end

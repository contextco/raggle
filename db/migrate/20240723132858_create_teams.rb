# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams, id: :uuid, &:timestamps

    add_reference :chats, :team, type: :uuid, foreign_key: true, index: true
  end
end

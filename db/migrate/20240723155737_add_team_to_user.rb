class AddTeamToUser < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :team, type: :uuid, foreign_key: true, index: true
  end
end

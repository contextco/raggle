class AddGoogleOauthToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :google_oauth, :jsonb
  end
end

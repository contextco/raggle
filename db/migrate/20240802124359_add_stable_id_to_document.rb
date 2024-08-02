class AddStableIdToDocument < ActiveRecord::Migration[7.1]
  def up
    add_column :documents, :stable_id, :string
    Document.find_each do |document|
      document.update!(stable_id: SecureRandom.uuid_v7)
    end
    add_check_constraint :documents, 'stable_id IS NOT NULL', name: 'check_stable_id_not_null', validate: false
  end

  def down
    remove_column :documents, :stable_id
    remove_check_constraint :documents, name: 'check_stable_id_not_null', if_exists: true
  end
end

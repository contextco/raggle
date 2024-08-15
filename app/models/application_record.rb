# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_create :generate_uuid

  private

  def generate_uuid
    self.id = SecureRandom.uuid_v7 if self.class.column_names.include?('id') && id.blank? && column_for_attribute('id').type == :uuid
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'associations' do
    it { should belong_to(:message) }
    it { should have_many(:chunks).dependent(:destroy) }
  end

  describe 'attributes' do
    it 'sets a default value for stable_id' do
      document = build(:document)
      expect(document.stable_id).to be_present
    end
  end
end

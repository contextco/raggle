# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chunk, type: :model do
  describe 'associations' do
    it { should belong_to(:document) }
  end

  describe 'validations' do
    it { should validate_presence_of(:chunk_index) }
    it { should validate_presence_of(:content) }
  end
end

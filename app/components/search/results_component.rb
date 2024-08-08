# frozen_string_literal: true

class Search::ResultsComponent < ApplicationComponent
  include Turbo::StreamsHelper

  attribute :query_id
end

# frozen_string_literal: true

module ::CoreExt
  module String
    def each_chunk(chunk_size, overlap = 0)
      return to_enum(:each_chunk, chunk_size, overlap) unless block_given?

      current_index = 0
      while current_index < length
        yield self[current_index, chunk_size]
        current_index += chunk_size - overlap
      end
    end
  end
end

class ::String
  include CoreExt::String
end

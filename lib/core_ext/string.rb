# frozen_string_literal: true

class String
  def each_chunk(chunk_size)
    return enum_for(:each_chunk, chunk_size) unless block_given?

    (0...length).step(chunk_size) do |start_idx|
      yield self[start_idx, chunk_size]
    end
  end
end

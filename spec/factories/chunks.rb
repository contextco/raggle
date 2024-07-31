FactoryBot.define do
  factory :chunk do
    uploaded_file { nil }
    chunk_index { 1 }
    content { "MyText" }
  end
end

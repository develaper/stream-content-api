FactoryBot.define do
  factory :app do
    sequence(:name) { |n| "Streaming App #{n}" }
  end
end

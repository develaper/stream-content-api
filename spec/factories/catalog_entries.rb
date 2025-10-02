FactoryBot.define do
  factory :catalog_entry do
    association :content, factory: :movie
  end
end

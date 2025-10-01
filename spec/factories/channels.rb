FactoryBot.define do
  factory :channel do
    title { "#{Faker::Company.name} #{[ 'TV', 'Channel', 'Network', 'Media' ].sample}" }
    year { nil }
    duration_in_seconds { nil }
  end
end

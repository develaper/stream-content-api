FactoryBot.define do
  factory :app do
    name { "#{Faker::Company.name} #{[ 'Stream', 'TV', 'Plus', 'Now', 'Play' ].sample}" }
  end
end

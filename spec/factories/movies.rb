FactoryBot.define do
  factory :movie do
    title { Faker::Movie.title }
    year { rand(1940..Date.current.year) }
    duration_in_seconds { rand(60*60..180*60) } # 1-3 hours
  end
end

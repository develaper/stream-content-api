FactoryBot.define do
  factory :season do
    title { "#{Faker::TvShows::GameOfThrones.house} - Season" }
    sequence(:number) { |n| n }
    year { rand(1940..Date.current.year) }
    duration_in_seconds { rand(5*60*60..20*60*60) } # 5-20 hours total
    association :tv_show
  end
end

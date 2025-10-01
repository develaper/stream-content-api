FactoryBot.define do
  factory :episode do
    title { [
      Faker::TvShows::GameOfThrones.quote,
      Faker::TvShows::Friends.quote,
      Faker::TvShows::BreakingBad.episode
    ].sample }
    sequence(:number) { |n| n }
    season_number { 1 }
    year { rand(1940..Date.current.year) }
    duration_in_seconds { rand(20*60..60*60) } # 20-60 minutes
    association :season

    after(:build) do |episode|
      episode.season_number = episode.season.number if episode.season
    end
  end
end

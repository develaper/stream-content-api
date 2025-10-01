FactoryBot.define do
  factory :tv_show do
    title { [
      Faker::TvShows::GameOfThrones.house,
      Faker::TvShows::Friends.character,
      Faker::TvShows::BreakingBad.character,
      Faker::TvShows::Simpsons.character
    ].sample }
    year { rand(1950..Date.current.year) }
    duration_in_seconds { nil } # TV shows often don't have total duration
  end
end

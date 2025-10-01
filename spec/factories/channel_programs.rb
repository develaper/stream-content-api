FactoryBot.define do
  factory :channel_program do
    title { "#{Faker::TvShows::Simpsons.character}'s #{[ 'Show', 'Hour', 'Live', 'Today' ].sample}" }
    year { rand(1940..Date.current.year) }
    duration_in_seconds { rand(30*60..120*60) } # 30-120 minutes
    association :channel
  end
end

FactoryBot.define do
  factory :content_availability do
    association :app
    association :market
    stream_url { Faker::Internet.url }

    trait :for_movie do
      association :content, factory: :movie
    end

    trait :for_tv_show do
      association :content, factory: :tv_show
    end

    trait :for_season do
      association :content, factory: :season
    end

    trait :for_episode do
      association :content, factory: :episode
    end

    trait :for_channel do
      association :content, factory: :channel
    end

    trait :for_channel_program do
      association :content, factory: :channel_program
    end
  end
end

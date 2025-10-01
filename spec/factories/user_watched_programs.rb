FactoryBot.define do
  factory :user_watched_program do
    user_identifier { SecureRandom.uuid }
    association :channel_program
    watched_duration { rand(1..7200) } # Random duration between 1 second and 2 hours

    trait :unwatched do
      watched_duration { 0 }
    end

    trait :favorite do
      watched_duration { 7200 } # 2 hours - likely to be a favorite
    end

    trait :with_specific_duration do
      transient do
        duration { 600 } # 10 minutes by default
      end

      watched_duration { duration }
    end
  end
end

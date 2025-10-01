FactoryBot.define do
  factory :user_favorite_app do
    user_identifier { SecureRandom.uuid }
    association :app
    position { 1 }

    trait :with_position do
      transient do
        position_number { 1 }
      end
      position { position_number }
    end
  end
end

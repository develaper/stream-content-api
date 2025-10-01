FactoryBot.define do
  factory :market do
    code { Faker::Address.country_code.upcase[0..1] }
  end
end

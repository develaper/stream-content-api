FactoryBot.define do
  factory :market do
    sequence(:code) { |n| %w[ES GB US FR DE IT NL BE AT CH].sample }
  end
end

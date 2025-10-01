FactoryBot.define do
  factory :program_schedule do
    start_time { Faker::Time.between_dates(from: Date.today, to: Date.today + 7, period: :day) }
    end_time { |ps| ps.start_time + Faker::Number.between(from: 30*60, to: 120*60) } # 30-120 minutes after start
    association :channel_program
  end
end

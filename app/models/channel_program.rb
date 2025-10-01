class ChannelProgram < ApplicationRecord
  include Contentable

  belongs_to :channel
  has_many :program_schedules, dependent: :destroy
end

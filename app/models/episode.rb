class Episode < ApplicationRecord
  include Contentable

  belongs_to :season

  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :season_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :year, presence: true, numericality: { only_integer: true }
  validates :duration_in_seconds, presence: true, numericality: { only_integer: true, greater_than: 0 }

  delegate :tv_show, to: :season
end

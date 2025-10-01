class TvShow < ApplicationRecord
  include Contentable

  has_many :seasons, dependent: :destroy
  has_many :episodes, through: :seasons

  validates :year, presence: true, numericality: { only_integer: true }
end

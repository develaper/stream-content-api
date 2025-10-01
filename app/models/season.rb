class Season < ApplicationRecord
  include Contentable

  belongs_to :tv_show
  has_many :episodes, dependent: :destroy

  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :year, presence: true, numericality: { only_integer: true }
end

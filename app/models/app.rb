class App < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :content_availabilities
  has_many :movies, through: :content_availabilities, source: :content, source_type: "Movie"
  has_many :tv_shows, through: :content_availabilities, source: :content, source_type: "TvShow"
  has_many :channels, through: :content_availabilities, source: :content, source_type: "Channel"
end

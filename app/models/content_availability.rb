class ContentAvailability < ApplicationRecord
  belongs_to :content, polymorphic: true
  belongs_to :app
  belongs_to :market

  validates :content, presence: true
  validates :app, presence: true
  validates :market, presence: true
  validates :app_id, uniqueness: { scope: [ :content_type, :content_id, :market_id ] }
end

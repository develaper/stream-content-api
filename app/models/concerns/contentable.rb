module Contentable
  extend ActiveSupport::Concern

  included do
    validates :title, presence: true

    has_many :content_availabilities, as: :content, dependent: :destroy
    has_many :apps, through: :content_availabilities
    has_many :markets, through: :content_availabilities
  end

  def content_type
    self.class.name.underscore
  end

  # Check if content is available in a specific market
  # @param market_code [String] The market code to check availability for
  # @return [Boolean] True if available in the specified market, false otherwise
  #
  def available_in?(market_code)
    content_availabilities.joins(:market).exists?(markets: { code: market_code.upcase })
  end

  # Check if content is available on a specific app
  # @param app_name [String] The app name to check availability for
  # @return [Boolean] True if available on the specified app, false otherwise
  #
  def available_on?(app_name)
    content_availabilities.joins(:app).exists?(apps: { name: app_name })
  end
end

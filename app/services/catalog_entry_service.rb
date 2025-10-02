class CatalogEntryService
  def initialize(country_code)
    @country_code = country_code
  end

  def list(content_type = nil)
    scope = CatalogEntry
      .joins("INNER JOIN content_availabilities ON content_availabilities.content_id = catalog_entries.content_id AND content_availabilities.content_type = catalog_entries.content_type")
      .joins("INNER JOIN markets ON content_availabilities.market_id = markets.id")
      .where(markets: { code: @country_code })
      .distinct
    scope = scope.where(content_type: content_type) if content_type
    scope.map { |entry| ContentItem.new(entry.content) }
  end

  def find(content_id, user_id = nil)
    entry = CatalogEntry.find_by(content_id: content_id)
    return nil unless entry
    ContentItem.new(entry.content, user_id: user_id)
  end
end

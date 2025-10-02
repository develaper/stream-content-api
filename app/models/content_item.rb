class ContentItem
  attr_reader :id, :title, :type, :year, :duration_in_seconds, :availabilities

  def initialize(content)
    @id = content.id
    @title = content.title
    @type = content.content_type
    @year = content.respond_to?(:year) ? content.year : nil
    @duration_in_seconds = content.respond_to?(:duration_in_seconds) ? content.duration_in_seconds : nil
    @availabilities = content.content_availabilities.map do |avail|
      {
        app: avail.app.name,
        market: avail.market.code
      }
    end
  end

  def as_json(options = {})
    {
      id: @id,
      title: @title,
      type: @type,
      year: @year,
      duration_in_seconds: @duration_in_seconds,
      availabilities: @availabilities
    }.compact
  end
end

class ContentSearchService
  def initialize(query)
    @query = query
  end

  def results
    items = Contentable.registered.flat_map do |model|
      if model.column_names.include?("year")
        model.where("title ILIKE ? OR CAST(year AS TEXT) ILIKE ?", "%#{@query}%", "%#{@query}%")
      else
        model.where("title ILIKE ?", "%#{@query}%")
      end
    end

    items = items.map { |item| ContentItem.new(item) }
    apps = App.where("name ILIKE ?", "%#{@query}%").map { |app| { type: "app", id: app.id, name: app.name } }
    items + apps
  end
end

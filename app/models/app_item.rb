class AppItem
  def initialize(app, position: nil)
    @app = app
    @position = position
  end

  def as_json(_options = {})
    {
      id: @app.id,
      name: @app.name,
      position: @position
    }.compact
  end
end

class ContentItem
  attr_reader :id, :title, :type, :year, :duration_in_seconds, :availabilities

  def initialize(content, user_id: nil)
    @user_id = user_id
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
    base ={
      id: @id,
      title: @title,
      type: @type,
      year: @year,
      duration_in_seconds: @duration_in_seconds,
      availabilities: @availabilities
    }.compact

    if @type == "channel_program" && @user_id.present?
      user_watched = UserWatchedProgram.find_by(user_identifier: @user_id, channel_program_id: @id)
      base[:time_watched] = user_watched ? user_watched.time_watched : 0
    end
    base
  end
end

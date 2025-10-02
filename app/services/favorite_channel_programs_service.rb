class FavoriteChannelProgramsService
  def initialize(user_id)
    @user_id = user_id
  end

  def favorites
    UserWatchedProgram
      .where(user_identifier: @user_id)
      .where.not(channel_program_id: nil)
      .order(watched_duration: :desc)
      .includes(:channel_program)
      .map { |uwp| ContentItem.new(uwp.channel_program, user_id: @user_id) }
  end
end

class UserWatchedProgram < ApplicationRecord
  belongs_to :channel_program

  validates :user_identifier, presence: true
  validates :watched_duration, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :channel_program_id, uniqueness: { scope: :user_identifier, message: "watch record already exists for this user" }

  scope :by_user, ->(user_id) { where(user_identifier: user_id).order(watched_duration: :desc) }

  # Scope to find favorite programs (most watched)
  scope :favorites, ->(user_id, limit = 10) { by_user(user_id).limit(limit) }

  def add_watched_time(seconds)
    return if seconds <= 0

    self.watched_duration += seconds
    save
  end
end

class UserFavoriteApp < ApplicationRecord
  belongs_to :app

  validates :user_identifier, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :app_id, uniqueness: { scope: :user_identifier, message: "has already been favorited by this user" }

  scope :by_user, ->(user_id) { where(user_identifier: user_id).order(:position) }

  after_create :adjust_positions_on_create
  after_update :adjust_positions_on_update

  private

  def user_favorites_except_self
    self.class.where(user_identifier: user_identifier).where.not(id: id)
  end

  def adjust_positions_on_create
    adjust_positions_for_conflict if position_conflict_exists?
  end

  def adjust_positions_on_update
    if saved_change_to_position?
      old_position, new_position = saved_change_to_position

      adjust_positions_for_update(old_position, new_position) unless old_position == new_position
    end
  end

  def position_conflict_exists?
    user_favorites_except_self.where(position: position).exists?
  end

  # Shifts positions within a range by a given offset
  def shift_positions(min_position, max_position = nil, offset)
    query = user_favorites_except_self.where("position >= ?", min_position)
    query = query.where("position <= ?", max_position) if max_position

    # Use proper ordering based on offset direction to avoid conflicts
    query = offset > 0 ? query.order(position: :desc) : query.order(:position)

    UserFavoriteApp.transaction do
      # Use a safe approach with Arel to avoid SQL injection
      query.update_all([ "position = position + ?", offset ])
    end
  end

  def adjust_positions_for_conflict
    # Shift positions >= current position up by 1
    shift_positions(position, nil, 1)
  end

  # Adjusts positions when updating a favorite's position
  def adjust_positions_for_update(old_position, new_position)
    if new_position > old_position
      # Moving down in the list - shift positions between old and new down by one
      shift_positions(old_position + 1, new_position, -1)
    elsif new_position < old_position
      # Moving up in the list - shift positions between new and old up by one
      shift_positions(new_position, old_position - 1, 1)
    end
  end
end

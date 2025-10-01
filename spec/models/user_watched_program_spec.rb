require 'rails_helper'

RSpec.describe UserWatchedProgram, type: :model do
  let(:user_id) { SecureRandom.uuid }

  describe 'associations' do
    it { should belong_to(:channel_program) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_identifier) }
    it { should validate_presence_of(:watched_duration) }
    it { should validate_numericality_of(:watched_duration).only_integer.is_greater_than_or_equal_to(0) }

    describe 'uniqueness validations' do
      let!(:channel_program) { create(:channel_program) }
      let!(:watched_program) { create(:user_watched_program, user_identifier: user_id, channel_program: channel_program) }

      it 'validates uniqueness of channel_program_id scoped to user_identifier' do
        duplicate = build(:user_watched_program, user_identifier: user_id, channel_program: channel_program)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:channel_program_id]).to include('watch record already exists for this user')
      end

      it 'allows same program for different users' do
        different_user = SecureRandom.uuid
        valid_record = build(:user_watched_program, user_identifier: different_user, channel_program: channel_program)
        expect(valid_record).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:channel_program1) { create(:channel_program) }
    let!(:channel_program2) { create(:channel_program) }
    let!(:channel_program3) { create(:channel_program) }

    let!(:watched1) { create(:user_watched_program, user_identifier: user_id, channel_program: channel_program1, watched_duration: 1800) }
    let!(:watched2) { create(:user_watched_program, user_identifier: user_id, channel_program: channel_program2, watched_duration: 3600) }
    let!(:watched3) { create(:user_watched_program, user_identifier: user_id, channel_program: channel_program3, watched_duration: 600) }
    let!(:other_user_watched) { create(:user_watched_program, channel_program: channel_program1) }

    it 'returns programs watched by a specific user ordered by most watched time' do
      watched_programs = UserWatchedProgram.by_user(user_id)
      expect(watched_programs.count).to eq(3)
      expect(watched_programs.first).to eq(watched2)  # Most watched (3600 seconds)
      expect(watched_programs.second).to eq(watched1) # Second most watched (1800 seconds)
      expect(watched_programs.last).to eq(watched3)   # Least watched (600 seconds)
    end

    it 'returns favorite programs limited by count' do
      favorites = UserWatchedProgram.favorites(user_id, 2)
      expect(favorites.count).to eq(2)
      expect(favorites).to include(watched2, watched1)
      expect(favorites).not_to include(watched3)
    end
  end

  describe '#add_watched_time' do
    let(:channel_program) { create(:channel_program) }
    let(:watched_program) { create(:user_watched_program, user_identifier: user_id, channel_program: channel_program, watched_duration: 600) }

    it 'increases watched duration by the specified seconds' do
      expect {
        watched_program.add_watched_time(300)
      }.to change { watched_program.reload.watched_duration }.from(600).to(900)
    end

    it 'does nothing if seconds is zero or negative' do
      expect {
        watched_program.add_watched_time(0)
      }.not_to change { watched_program.reload.watched_duration }

      expect {
        watched_program.add_watched_time(-100)
      }.not_to change { watched_program.reload.watched_duration }
    end
  end
end

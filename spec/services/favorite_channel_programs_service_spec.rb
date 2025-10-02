require 'rails_helper'

RSpec.describe FavoriteChannelProgramsService do
  let(:user_id) { 'user_123' }
  let(:channel) { create(:channel, title: 'Test Channel') }
  let!(:program1) { create(:channel_program, title: 'Program 1', channel: channel) }
  let!(:program2) { create(:channel_program, title: 'Program 2', channel: channel) }
  let!(:uwp1) { create(:user_watched_program, user_identifier: user_id, channel_program: program1, watched_duration: 100) }
  let!(:uwp2) { create(:user_watched_program, user_identifier: user_id, channel_program: program2, watched_duration: 200) }

  it 'returns favorite channel programs ordered by watched duration' do
    service = FavoriteChannelProgramsService.new(user_id)
    results = service.favorites
    expect(results.map(&:title)).to eq([ 'Program 2', 'Program 1' ])
  end

  it 'returns an empty array if user has no favorites' do
    service = FavoriteChannelProgramsService.new('unknown_user')
    results = service.favorites
    expect(results).to be_empty
  end
end

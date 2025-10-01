require 'rails_helper'

RSpec.describe Episode, type: :model do
  subject { build(:episode) }

  it_behaves_like 'contentable'

  it { should belong_to(:season) }

  it { should validate_presence_of(:number) }
  it { should validate_numericality_of(:number).only_integer.is_greater_than(0) }

  it { should validate_presence_of(:season_number) }
  it { should validate_numericality_of(:season_number).only_integer.is_greater_than(0) }

  it { should validate_presence_of(:year) }
  it { should validate_numericality_of(:year).only_integer }

  it { should validate_presence_of(:duration_in_seconds) }
  it { should validate_numericality_of(:duration_in_seconds).only_integer.is_greater_than(0) }

  describe '#content_type' do
    it 'returns "episode"' do
      expect(subject.content_type).to eq('episode')
    end
  end

  describe '#tv_show' do
    let(:tv_show) { create(:tv_show) }
    let(:season) { create(:season, tv_show: tv_show) }
    let(:episode) { create(:episode, season: season) }
    it 'delegates to season' do
      expect(episode.tv_show).to eq(tv_show)
    end
  end
end

require 'rails_helper'

RSpec.describe TvShow, type: :model do
  subject { build(:tv_show) }

  it_behaves_like 'contentable'

  describe '#content_type' do
    it 'returns "tv_show"' do
      expect(subject.content_type).to eq('tv_show')
    end
  end
end

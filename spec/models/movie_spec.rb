require 'rails_helper'

RSpec.describe Movie, type: :model do
  subject { build(:movie) }

  it_behaves_like 'contentable'

  describe '#content_type' do
    it 'returns "movie"' do
      expect(subject.content_type).to eq('movie')
    end
  end
end

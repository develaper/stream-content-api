require 'rails_helper'

RSpec.describe Channel, type: :model do
  subject { build(:channel) }

  it_behaves_like 'contentable'

  describe '#content_type' do
    it 'returns "channel"' do
      expect(subject.content_type).to eq('channel')
    end
  end
end

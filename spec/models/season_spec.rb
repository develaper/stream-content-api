require 'rails_helper'

RSpec.describe Season, type: :model do
  subject { build(:season) }

  it_behaves_like 'contentable'

  it { should belong_to(:tv_show) }
  it { should have_many(:episodes).dependent(:destroy) }

  it { should validate_presence_of(:number) }
  it { should validate_numericality_of(:number).only_integer.is_greater_than(0) }

  it { should validate_presence_of(:year) }
  it { should validate_numericality_of(:year).only_integer }

  describe '#content_type' do
    it 'returns "season"' do
      expect(subject.content_type).to eq('season')
    end
  end
end

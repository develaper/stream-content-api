require 'rails_helper'

RSpec.describe Market, type: :model do
  subject { build(:market) }

  describe 'validations' do
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code).case_insensitive }
    it { should validate_length_of(:code).is_equal_to(2) }

    context 'when code is missing' do
      it 'is invalid' do
        market = build(:market, code: nil)
        expect(market).to be_invalid
        expect(market.errors[:code]).to include("can't be blank")
      end
    end
  end

  describe 'upcase callback' do
    it 'upcases the code before validation' do
      market = create(:market, code: 'es')
      expect(market.code).to eq('ES')
    end
  end
end

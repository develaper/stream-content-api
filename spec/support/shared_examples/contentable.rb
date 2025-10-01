require 'rails_helper'

RSpec.shared_examples 'contentable' do
  it { should validate_presence_of(:title) }
  it { should have_many(:content_availabilities).dependent(:destroy) }
  it { should have_many(:apps).through(:content_availabilities) }
  it { should have_many(:markets).through(:content_availabilities) }

  describe '#content_type' do
    it 'returns the underscored class name' do
      expect(subject.content_type).to eq(described_class.name.underscore)
    end
  end

  describe '#available_in?' do
    let(:market) { create(:market, code: 'US') }
    let(:app) { create(:app) }

    context 'when content is available in the market' do
      before do
        subject.save!
        create(:content_availability, content: subject, market: market, app: app)
      end

      it 'returns true' do
        expect(subject.available_in?('US')).to be true
      end
    end

    context 'when content is not available in the market' do
      it 'returns false' do
        expect(subject.available_in?('US')).to be false
      end
    end
  end

  describe '#available_on?' do
    let(:market) { create(:market) }
    let(:app) { create(:app, name: 'Netflix') }

    context 'when content is available on the app' do
      before do
        subject.save!
        create(:content_availability, content: subject, market: market, app: app)
      end

      it 'returns true' do
        expect(subject.available_on?('Netflix')).to be true
      end
    end

    context 'when content is not available on the app' do
      it 'returns false' do
        expect(subject.available_on?('Netflix')).to be false
      end
    end
  end
end

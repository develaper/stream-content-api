require 'rails_helper'

RSpec.describe CatalogEntryService do
  let(:market) { create(:market, code: 'US') }
  let(:movie) { create(:movie, title: 'Test Movie', year: 2023) }
  let(:app) { create(:app, name: 'Netflix') }
  let!(:availability) { create(:content_availability, content: movie, app: app, market: market) }

  describe '#list' do
    it 'returns content items for the given market' do
      service = CatalogEntryService.new('US')
      results = service.list('Movie')
      expect(results.map(&:title)).to include('Test Movie')
    end
  end

  describe '#find' do
    it 'returns a content item for a valid content_id' do
      service = CatalogEntryService.new('US')
      item = service.find(movie.id)
      expect(item.title).to eq('Test Movie')
    end

    it 'returns nil for an invalid content_id' do
      service = CatalogEntryService.new('US')
      item = service.find(9999)
      expect(item).to be_nil
    end
  end
end

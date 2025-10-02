require 'rails_helper'

RSpec.describe CatalogEntry, type: :model do
  describe 'associations' do
    it { should belong_to(:content) }
  end

  describe 'polymorphic association' do
    it 'creates a CatalogEntry for a Movie after creation' do
      movie = create(:movie, title: 'Test Movie', year: 2023)
      catalog_entry = CatalogEntry.find_by(content: movie)
      expect(catalog_entry).not_to be_nil
      expect(catalog_entry.content).to eq(movie)
      expect(catalog_entry.content_type).to eq('Movie')
    end

    it 'creates a CatalogEntry for a TvShow after creation' do
      tv_show = create(:tv_show, title: 'Test Show', year: 2022)
      catalog_entry = CatalogEntry.find_by(content: tv_show)
      expect(catalog_entry).not_to be_nil
      expect(catalog_entry.content).to eq(tv_show)
      expect(catalog_entry.content_type).to eq('TvShow')
    end
  end
end

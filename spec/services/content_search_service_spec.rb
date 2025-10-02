require 'rails_helper'

RSpec.describe ContentSearchService do
  let!(:movie) { create(:movie, title: 'Test Movie', year: 2023) }
  let!(:tv_show) { create(:tv_show, title: 'Test TV Show', year: 2022) }
  let!(:channel) { create(:channel, title: 'Test Channel') }
  let!(:channel_program) { create(:channel_program, title: 'Test Program', year: 2021, channel: channel) }
  let!(:app) { create(:app, name: 'Netflix') }
  let!(:app2) { create(:app, name: 'Test Flix') }

  it 'returns matching content items for a query' do
    service = ContentSearchService.new('Test')
    results = service.results
    titles = results.map { |item| item.respond_to?(:title) ? item.title : item[:name] }
    expect(titles).to include('Test Movie', 'Test TV Show', 'Test Channel', 'Test Program', 'Test Flix')
  end

  it 'returns apps for an app name query, along with any matching content items' do
    service = ContentSearchService.new('Netflix')
    results = service.results
    expect(results.any? { |item| item[:type] == 'app' && item[:name] == 'Netflix' }).to be true
    # Optionally, check that other content items are present if they match
  end

  it 'returns empty array for no matches' do
    service = ContentSearchService.new('Nonexistent')
    results = service.results
    expect(results).to be_empty
  end
end

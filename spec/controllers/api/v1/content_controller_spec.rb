require 'rails_helper'

RSpec.describe Api::V1::ContentController, type: :controller do
  let(:market_us) { create(:market, code: 'US') }
  let(:market_es) { create(:market, code: 'ES') }
  let(:app_netflix) { create(:app, name: 'Netflix') }
  let(:app_prime) { create(:app, name: 'Prime Video') }

  let(:movie) { create(:movie, title: 'Test Movie', year: 2023) }
  let(:tv_show) { create(:tv_show, title: 'Test TV Show', year: 2022) }
  let(:channel) { create(:channel, title: 'Test Channel') }

  before do
    # Set up content availabilities for different regions
    create(:content_availability, content: movie, app: app_netflix, market: market_us)
    create(:content_availability, content: tv_show, app: app_prime, market: market_us)
    create(:content_availability, content: tv_show, app: app_netflix, market: market_es)
    create(:content_availability, content: channel, app: app_prime, market: market_es)
  end

  describe 'GET #index' do
    it 'returns an error if country parameter is missing' do
      get :index
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']).to eq('Country parameter is required')
    end

    context 'with country filter' do
      it 'returns all content types available in US' do
        get :index, params: { country: 'US' }
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json.size).to eq(2) # 1 movie, 1 TV show

        content_types = json.map { |item| item['type'] }
        expect(content_types).to include('movie', 'tv_show')
      end

      it 'returns all content types available in ES' do
        get :index, params: { country: 'ES' }
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json.size).to eq(2) # 1 TV show, 1 channel

        content_types = json.map { |item| item['type'] }
        expect(content_types).to include('tv_show', 'channel')
      end
    end

    context 'with type and country filter' do
      it 'returns only movies in US' do
        get :index, params: { country: 'US', type: 'movie' }
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json.size).to eq(1)
        expect(json.first['title']).to eq('Test Movie')
      end

      it 'returns only TV shows in ES' do
        get :index, params: { country: 'ES', type: 'tv_show' }
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json.size).to eq(1)
        expect(json.first['title']).to eq('Test TV Show')
      end

      it 'returns an error for invalid content type' do
        get :index, params: { country: 'US', type: 'invalid' }
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('Invalid content type')
      end
    end
  end
end

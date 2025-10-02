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

  describe 'GET #show' do
    it 'returns content details for a valid content ID' do
      get :show, params: { id: movie.id }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['title']).to eq('Test Movie')
      expect(json['type']).to eq('movie')
    end

    it 'returns not found for an invalid content ID' do
      get :show, params: { id: 9999 }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Content not found')
    end

    it 'includes time_watched for ChannelProgram when user_id is provided' do
      channel_program = create(:channel_program, title: 'Test Program', channel: channel)
      user_identifier = "user_123"
      create(:user_watched_program, user_identifier: user_identifier, channel_program: channel_program, watched_duration: 120)

      get :show, params: { id: channel_program.id, user_id: user_identifier }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['title']).to eq('Test Program')
      expect(json['type']).to eq('channel_program')
      expect(json['time_watched']).to eq(120)
    end

    it 'returns content details without time_watched if user_id is not provided for ChannelProgram' do
      channel_program = create(:channel_program, title: 'Test Program', channel: channel)

      get :show, params: { id: channel_program.id }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['title']).to eq('Test Program')
      expect(json['type']).to eq('channel_program')
      expect(json).not_to have_key('time_watched')
    end
  end

  describe 'GET #favorite_channel_programs' do
    let(:user_identifier) { "user_456" }
    let!(:program1) { create(:channel_program, title: 'Program 1', channel: channel) }
    let!(:program2) { create(:channel_program, title: 'Program 2', channel: channel) }
    let!(:program3) { create(:channel_program, title: 'Program 3', channel: channel) }

    before do
      create(:user_watched_program, user_identifier: user_identifier, channel_program: program1, watched_duration: 300)
      create(:user_watched_program, user_identifier: user_identifier, channel_program: program2, watched_duration: 150)
      create(:user_watched_program, user_identifier: user_identifier, channel_program: program3, watched_duration: 450)
    end

    it 'returns an error if user_id parameter is missing' do
      get :favorite_channel_programs
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']).to eq('user_id parameter is required')
    end

    it 'returns favorite channel programs ordered by watched duration' do
      get :favorite_channel_programs, params: { user_id: user_identifier }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
      expect(json.map { |item| item['title'] }).to eq(['Program 3', 'Program 1', 'Program 2'])
      expect(json.map { |item| item['time_watched'] }).to eq([450, 300, 150])
    end

    it 'returns an empty array if the user has no watched programs' do
      get :favorite_channel_programs, params: { user_id: 'unknown_user' }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to be_empty
    end
  end
end

require 'rails_helper'

RSpec.describe Api::V1::AppsController, type: :controller do
  let(:user_id) { SecureRandom.uuid }
  let!(:app1) { create(:app, name: 'Netflix') }
  let!(:app2) { create(:app, name: 'Prime Video') }
  let!(:app3) { create(:app, name: 'Hulu') }

  describe 'GET #favorites' do
    before do
      create(:user_favorite_app, user_identifier: user_id, app: app1, position: 2)
      create(:user_favorite_app, user_identifier: user_id, app: app2, position: 1)
      create(:user_favorite_app, user_identifier: user_id, app: app3, position: 3)
    end

    it 'returns an error if user_id is missing' do
      get :favorites
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']).to eq('user_id parameter is required')
    end

    it 'returns favorite apps for the user ordered by position' do
      get :favorites, params: { user_id: user_id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
      expect(json.map { |a| a['name'] }).to eq([ 'Prime Video', 'Netflix', 'Hulu' ])
      expect(json.map { |a| a['position'] }).to eq([ 1, 2, 3 ])
    end
  end

  describe 'POST #favorite' do
    it 'returns an error if required params are missing' do
      post :favorite, params: { user_id: user_id }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']).to eq('Missing parameters')
    end

    it 'creates a new favorite app and sets its position' do
      post :favorite, params: { user_id: user_id, app_id: app1.id, position: 1 }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['name']).to eq('Netflix')
      expect(json['position']).to eq(1)
    end

    it 'updates the position of an existing favorite app' do
      create(:user_favorite_app, user_identifier: user_id, app: app2, position: 1)
      post :favorite, params: { user_id: user_id, app_id: app2.id, position: 3 }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['name']).to eq('Prime Video')
      expect(json['position']).to eq(3)
    end

    it 'returns errors for invalid position' do
      post :favorite, params: { user_id: user_id, app_id: app1.id, position: 0 }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to be_present
    end
  end
end

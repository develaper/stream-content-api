require 'rails_helper'

RSpec.describe UserFavoriteApp, type: :model do
  let(:user_id) { SecureRandom.uuid }

  describe 'associations' do
    it { should belong_to(:app) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_identifier) }
    it { should validate_presence_of(:position) }
    it { should validate_numericality_of(:position).only_integer.is_greater_than(0) }

    describe 'uniqueness validations' do
      let!(:app) { create(:app) }
      let!(:favorite) { create(:user_favorite_app, user_identifier: user_id, app: app, position: 1) }

      it 'validates uniqueness of app_id scoped to user_identifier' do
        duplicate = build(:user_favorite_app, user_identifier: user_id, app: app, position: 2)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:app_id]).to include('has already been favorited by this user')
      end

      it 'allows same app for different users' do
        different_user = SecureRandom.uuid
        valid_favorite = build(:user_favorite_app, user_identifier: different_user, app: app, position: 1)
        expect(valid_favorite).to be_valid
      end

      it 'allows same position for different users' do
        different_user = SecureRandom.uuid
        valid_position = build(:user_favorite_app, user_identifier: different_user, app: create(:app), position: 1)
        expect(valid_position).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:app1) { create(:app) }
    let!(:app2) { create(:app) }
    let!(:app3) { create(:app) }
    let!(:favorite1) { create(:user_favorite_app, user_identifier: user_id, app: app1, position: 2) }
    let!(:favorite2) { create(:user_favorite_app, user_identifier: user_id, app: app2, position: 1) }
    let!(:favorite3) { create(:user_favorite_app, user_identifier: user_id, app: app3, position: 3) }
    let!(:other_user_favorite) { create(:user_favorite_app, app: app1) }

    it 'returns favorites for a specific user ordered by position' do
      favorites = UserFavoriteApp.by_user(user_id)
      expect(favorites.count).to eq(3)
      expect(favorites.first).to eq(favorite2)  # Position 1
      expect(favorites.second).to eq(favorite1) # Position 2
      expect(favorites.last).to eq(favorite3)   # Position 3
    end
  end

  describe 'position management' do
    let!(:app1) { create(:app) }
    let!(:app2) { create(:app) }
    let!(:app3) { create(:app) }

    it 'maintains position integrity when favorites are created and removed' do
      # Create favorites with positions 1, 2, and 3
      favorite1 = create(:user_favorite_app, user_identifier: user_id, app: app1, position: 1)
      favorite2 = create(:user_favorite_app, user_identifier: user_id, app: app2, position: 2)
      favorite3 = create(:user_favorite_app, user_identifier: user_id, app: app3, position: 3)

      # Delete the middle one
      favorite2.destroy

      # Create a new favorite with position 2 (should maintain order)
      app4 = create(:app)
      favorite4 = create(:user_favorite_app, user_identifier: user_id, app: app4, position: 2)

      # Reload from database
      favorite1.reload
      favorite3.reload
      favorite4.reload

      # Check positions are now 1, 2, and 3
      expect(favorite1.position).to eq(1)
      expect(favorite4.position).to eq(2)
      expect(favorite3.position).to eq(3)
    end
  end

  describe 'position shifting behavior' do
    let!(:app1) { create(:app) }
    let!(:app2) { create(:app) }
    let!(:app3) { create(:app) }
    let!(:app4) { create(:app) }

    context 'when creating a new favorite' do
      it 'shifts existing favorites when a new favorite is added with an existing position' do
        # Create favorites with positions 1, 2, and 3
        favorite1 = create(:user_favorite_app, user_identifier: user_id, app: app1, position: 1)
        favorite2 = create(:user_favorite_app, user_identifier: user_id, app: app2, position: 2)
        favorite3 = create(:user_favorite_app, user_identifier: user_id, app: app3, position: 3)

        # Add a new favorite with position 2 (should push favorite2 to 3 and favorite3 to 4)
        favorite4 = create(:user_favorite_app, user_identifier: user_id, app: app4, position: 2)

        # Reload all records
        [ favorite1, favorite2, favorite3, favorite4 ].each(&:reload)

        # Check positions are updated correctly
        expect(favorite1.position).to eq(1) # Unchanged
        expect(favorite4.position).to eq(2) # Got the requested position
        expect(favorite2.position).to eq(3) # Pushed down
        expect(favorite3.position).to eq(4) # Pushed down
      end

      it 'does not affect favorites with lower positions' do
        # Create favorites with positions 1, 2, and 3
        favorite1 = create(:user_favorite_app, user_identifier: user_id, app: app1, position: 1)
        favorite2 = create(:user_favorite_app, user_identifier: user_id, app: app2, position: 2)
        favorite3 = create(:user_favorite_app, user_identifier: user_id, app: app3, position: 3)

        # Add a new favorite with position 3
        favorite4 = create(:user_favorite_app, user_identifier: user_id, app: app4, position: 3)

        # Reload all records
        [ favorite1, favorite2, favorite3, favorite4 ].each(&:reload)

        # Check positions are updated correctly
        expect(favorite1.position).to eq(1) # Unchanged
        expect(favorite2.position).to eq(2) # Unchanged
        expect(favorite4.position).to eq(3) # Got the requested position
        expect(favorite3.position).to eq(4) # Pushed down
      end

      it 'handles adding a favorite with a position higher than any existing position' do
        # Create favorites with positions 1, 2
        favorite1 = create(:user_favorite_app, user_identifier: user_id, app: app1, position: 1)
        favorite2 = create(:user_favorite_app, user_identifier: user_id, app: app2, position: 2)

        # Add a new favorite with position 5 (higher than any existing)
        favorite3 = create(:user_favorite_app, user_identifier: user_id, app: app3, position: 5)

        # Reload all records
        [ favorite1, favorite2, favorite3 ].each(&:reload)

        # Check positions remain as is
        expect(favorite1.position).to eq(1)
        expect(favorite2.position).to eq(2)
        expect(favorite3.position).to eq(5)
      end
    end

    context 'when updating an existing favorite' do
      it 'shifts positions down when moving a favorite to a lower position' do
        # Create favorites with positions 1, 2, 3
        favorite1 = create(:user_favorite_app, user_identifier: user_id, app: app1, position: 1)
        favorite2 = create(:user_favorite_app, user_identifier: user_id, app: app2, position: 2)
        favorite3 = create(:user_favorite_app, user_identifier: user_id, app: app3, position: 3)

        # Move favorite3 from position 3 to position 1
        favorite3.update(position: 1)

        # Reload all records
        [ favorite1, favorite2, favorite3 ].each(&:reload)

        # Check positions - favorite3 got position 1, others shifted up
        expect(favorite3.position).to eq(1)
        expect(favorite1.position).to eq(2)
        expect(favorite2.position).to eq(3)
      end

      it 'shifts positions up when moving a favorite to a higher position' do
        # Create favorites with positions 1, 2, 3, 4
        favorite1 = create(:user_favorite_app, user_identifier: user_id, app: app1, position: 1)
        favorite2 = create(:user_favorite_app, user_identifier: user_id, app: app2, position: 2)
        favorite3 = create(:user_favorite_app, user_identifier: user_id, app: app3, position: 3)
        favorite4 = create(:user_favorite_app, user_identifier: user_id, app: app4, position: 4)

        # Move favorite1 from position 1 to position 3
        favorite1.update(position: 3)

        # Reload all records
        [ favorite1, favorite2, favorite3, favorite4 ].each(&:reload)

        # Check positions - positions 2 and 3 shifted down, favorite1 is now 3
        expect(favorite2.position).to eq(1)
        expect(favorite3.position).to eq(2)
        expect(favorite1.position).to eq(3)
        expect(favorite4.position).to eq(4) # Unchanged
      end
    end
  end
end

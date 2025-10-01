require 'rails_helper'

RSpec.describe ContentAvailability, type: :model do
  subject { build(:content_availability, :for_movie) }

  it { should belong_to(:content) }
  it { should belong_to(:app) }
  it { should belong_to(:market) }

  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:app) }
  it { should validate_presence_of(:market) }

  describe "validations" do
    # Define common objects used across validation tests
    let(:app) { create(:app) }
    let(:movie) { create(:movie) }
    let(:movie2) { create(:movie) }
    let(:market) { create(:market) }
    let(:market_us) { create(:market, code: 'US') }
    let(:market_gb) { create(:market, code: 'GB') }

    it "validates uniqueness of app_id scoped to content_type, content_id, and market_id" do
      # Create the first content availability
      create(:content_availability, content: movie, app: app, market: market)

      # Attempt to create a duplicate
      duplicate = build(:content_availability, content: movie, app: app, market: market)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:app_id]).to include("has already been taken")
    end

    it "allows the same app for different content" do
      create(:content_availability, content: movie, app: app, market: market)
      duplicate = build(:content_availability, content: movie2, app: app, market: market)

      expect(duplicate).to be_valid
    end

    it "allows the same app for same content but different market" do
      create(:content_availability, content: movie, app: app, market: market_us)
      duplicate = build(:content_availability, content: movie, app: app, market: market_gb)

      expect(duplicate).to be_valid
    end
  end

  describe "polymorphic associations" do
    it "can be associated with a movie" do
      content_availability = create(:content_availability, :for_movie)
      expect(content_availability.content).to be_a(Movie)
    end

    it "can be associated with a tv show" do
      content_availability = create(:content_availability, :for_tv_show)
      expect(content_availability.content).to be_a(TvShow)
    end

    it "can be associated with a season" do
      content_availability = create(:content_availability, :for_season)
      expect(content_availability.content).to be_a(Season)
    end

    it "can be associated with an episode" do
      content_availability = create(:content_availability, :for_episode)
      expect(content_availability.content).to be_a(Episode)
    end

    it "can be associated with a channel" do
      content_availability = create(:content_availability, :for_channel)
      expect(content_availability.content).to be_a(Channel)
    end

    it "can be associated with a channel program" do
      content_availability = create(:content_availability, :for_channel_program)
      expect(content_availability.content).to be_a(ChannelProgram)
    end
  end
end

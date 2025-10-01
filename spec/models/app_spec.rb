require 'rails_helper'

RSpec.describe App, type: :model do
  subject { build(:app) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end
end

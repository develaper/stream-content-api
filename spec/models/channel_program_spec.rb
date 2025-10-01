require 'rails_helper'

RSpec.describe ChannelProgram, type: :model do
  subject { build(:channel_program) }

  it_behaves_like 'contentable'

  it { should belong_to(:channel) }
  it { should have_many(:program_schedules).dependent(:destroy) }

  describe '#content_type' do
    it 'returns "channel_program"' do
      expect(subject.content_type).to eq('channel_program')
    end
  end
end

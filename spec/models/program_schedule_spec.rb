require 'rails_helper'

RSpec.describe ProgramSchedule, type: :model do
  subject { build(:program_schedule) }

  it { should belong_to(:channel_program) }
  it { should validate_presence_of(:start_time) }
  it { should validate_presence_of(:end_time) }

  describe "validations" do
    context "when end_time is before start_time" do
      before do
        subject.start_time = Time.current
        subject.end_time = 1.hour.ago
      end

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:end_time]).to include("must be after start time")
      end
    end

    context "when end_time is after start_time" do
      before do
        subject.start_time = Time.current
        subject.end_time = 1.hour.from_now
      end

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end

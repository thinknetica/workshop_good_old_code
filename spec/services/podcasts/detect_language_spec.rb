require "rails_helper"

RSpec.describe Podcasts::DetectLanguage do
  let(:podcast) { create(:podcast, description: 'Let me introduce myself') }

  it "detects podcast's language" do
    expect(described_class.call(podcast)).to eq(:en)
  end
end

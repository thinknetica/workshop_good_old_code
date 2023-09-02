require 'rails_helper'

RSpec.describe Podcast, type: :model do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }

  it "is valid" do
    expect(podcast.valid?).to be_truthy
  end
end

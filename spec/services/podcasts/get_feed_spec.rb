require "rails_helper"

vcr_options = {
  cassette_name: "se_daily_rss_feed",
  allow_playback_repeats: "true"
}

RSpec.describe Podcasts::GetFeed, vcr: vcr_options do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }
  let(:result) { described_class.new(podcast).call }

  it 'detects podcast\'s language and returns it as symbol' do
    expect(described_class.call(podcast)).to be_an_instance_of RSS::Rss
  end

  it "returns error" do
    allow(HTTParty).to receive(:get).with(feed_url).and_raise(Errno::ECONNREFUSED)
    expect(result.success).to be_falsey
    expect(result.error).to be_present
  end
end
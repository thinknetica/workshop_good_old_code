require "rails_helper"

vcr_options = {
  cassette_name: "se_daily_rss_feed",
  allow_playback_repeats: "true"
}

RSpec.describe Podcasts::DetectLanguage, vcr: vcr_options do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url, description: 'Thank you podcast') }

  it 'detects podcast\'s language and returns it as symbol' do
    expect(described_class.call(podcast.description)).to eq :en
  end
end
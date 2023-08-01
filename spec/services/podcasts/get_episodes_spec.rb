require "rails_helper"

# Podcast.skip_callback :commit, :after, :pull_all_episodes
# Podcast.set_callback :commit, :after, :pull_all_episodes

vcr_options = {
  cassette_name: "se_daily_rss_feed",
  allow_playback_repeats: "true",
}

RSpec.describe Podcasts::GetEpisodes, vcr: vcr_options do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }

  let(:feed_path) { "../../support/fixtures/se_daily_rss_feed.rss" }
  let(:feed) { File.read(File.join(File.dirname(__FILE__), feed_path)) }

  let(:unpodcast_rss) { "http://podcast.example.com/podcast" }

  it "fetches episodes" do
    expect {
      described_class.new(podcast).call
    }.to change(podcast.podcast_episodes, :count)
  end

  it "fetches correct episodes" do
    described_class.new(podcast).call
    expect(podcast.podcast_episodes.find_by(title: "Engineering Insights with Christina Forney")).to be_a(PodcastEpisode)
  end
end

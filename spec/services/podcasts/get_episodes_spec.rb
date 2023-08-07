require "rails_helper"

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
    expect(podcast.podcast_episodes.find_by(title: "Engineering Insights with Christina Forney").present?).to be false
    described_class.new(podcast).call(limit: 2)
    expect(podcast.podcast_episodes.find_by(title: "Engineering Insights with Christina Forney")).to be_a(PodcastEpisode)
  end

  it "handles errors" do
    allow(HTTParty).to receive(:get).with(feed_url).and_raise(Errno::ECONNREFUSED)
    described_class.new(podcast).call(limit: 2)
    podcast.reload
    expect(podcast.status_notice).to include("Unreachable")
  end

  context "with Result object" do
    it "returns success" do
    end

    it "returns error" do
    end

    it "returns episodes count" do
    end
  end
end

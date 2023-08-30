require "rails_helper"

vcr_options = {
  cassette_name: "se_daily_rss_feed",
  allow_playback_repeats: "true",
}

RSpec.describe Podcasts::GetEpisodes, vcr: vcr_options do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }
  let(:podcast_title) { "Engineering Insights with Christina Forney" }

  let(:feed_path) { "../../support/fixtures/se_daily_rss_feed.rss" }
  let(:feed) { File.read(File.join(File.dirname(__FILE__), feed_path)) }

  let(:unpodcast_rss) { "http://podcast.example.com/podcast" }

  it "fetches episodes" do
    expect { described_class.call(podcast) }.to change(podcast.podcast_episodes, :count)
  end

  it "fetches correct episodes" do
    aggregate_failures do
      expect(podcast.podcast_episodes.find_by(title: podcast_title).present?).to be false
      described_class.call(podcast)
      expect(podcast.podcast_episodes.find_by(title: podcast_title)).to be_a(PodcastEpisode)
    end
  end

  it "handles errors" do
    allow(HTTParty).to receive(:get).with(feed_url).and_raise(Errno::ECONNREFUSED)
    described_class.call(podcast)
    podcast.reload
    expect(podcast.status_notice).to include("Unreachable")
  end

  context "with Result object" do
    let(:result) { described_class.call(podcast) }

    it "returns success" do
      aggregate_failures do
        expect(result.success).to be_truthy
        expect(result.error).to be_blank
      end
    end

    it "returns error" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(Errno::ECONNREFUSED)

      aggregate_failures do
        expect(result.success).to be_falsey
        expect(result.error).to eq("Connection refused")
      end
    end

    it "returns episodes count" do
      stub_request(:get, feed_url).to_return(body: feed, status: 200)
      expect(result.new_episodes_count).to eq(100)
    end
  end
end

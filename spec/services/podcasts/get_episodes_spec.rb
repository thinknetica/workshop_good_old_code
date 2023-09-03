require "rails_helper"

vcr_options = {
  cassette_name: "se_daily_rss_feed",
  allow_playback_repeats: "true",
}

RSpec.describe Podcasts::GetEpisodes, vcr: vcr_options do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }

  context 'checking limit param' do
    before do
      stub_request(:head, /https:\/\/traffic.megaphone.fm/).to_return({ status: 200, body: "", headers: {} })
    end

    it "fetches episodes by default limit" do
      described_class.new(podcast).call(limit: 100)
      expect(podcast.podcast_episodes.count).to eq(100)
    end

    it "fetches episodes by certain limit" do
      described_class.new(podcast).call(limit: 50)
      expect(podcast.podcast_episodes.count).to eq(50)
    end

    it "fetches episodes by negative limit" do
      described_class.new(podcast).call(limit: -50)
      expect(podcast.podcast_episodes.count).to eq(50)
    end
  end

  context 'fetching correct podcast episodes' do
    it "fetches correct episodes" do
      stub_request(:head, /https:\/\/traffic.megaphone.fm/).to_return({ status: 200, body: "", headers: {} })
      expect(podcast.podcast_episodes.count).to eq(0)
      expect(podcast.podcast_episodes.find_by(title: "SDKs for your API with Sagar Batchu").present?).to be_falsey

      described_class.new(podcast).call(limit: 2)
      expect(podcast.podcast_episodes.count).to eq(2)
      expect(podcast.podcast_episodes.find_by(title: "SDKs for your API with Sagar Batchu")).to be_a(PodcastEpisode)
    end

    it "fetches reachable podcast episode" do
      stub_request(:head, /https:\/\/traffic.megaphone.fm/).to_return({ status: 200, body: "", headers: {} })
      described_class.new(podcast).call(limit: 1)
      expect(podcast.podcast_episodes.first.reachable).to be_truthy
    end

    it "fetches unreachable podcast episode" do
      stub_request(:head, /https:\/\/traffic.megaphone.fm/).to_return({ status: 404, body: "", headers: {} })
      described_class.new(podcast).call(limit: 1)
      expect(podcast.podcast_episodes.first.reachable).to be_falsey
    end
  end

  context "with Result object" do
    let(:result) { described_class.new(podcast).call(limit: 50) }

    before do
      stub_request(:head, /https:\/\/traffic.megaphone.fm/).to_return({ status: 200, body: "", headers: {} })
    end

    it "returns success" do
      expect(result.success).to be_truthy
    end

    it "returns error" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(Net::OpenTimeout)
      expect(result.error).to be_present
      expect(result.success).to be_falsey
    end

    it "returns episodes count" do
      expect(result.new_episodes_count).to eq(50)
    end
  end
end

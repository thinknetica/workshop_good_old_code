require "rails_helper"

vcr_options = {
  cassette_name: "se_daily_rss_feed",
  allow_playback_repeats: "true",
}

RSpec.describe Podcasts::GetEpisodes, vcr: vcr_options do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }

  # concerning!
  before do
    Podcast.skip_callback(:commit, :after, :pull_all_episodes)
  end

  # concerning!
  after do
    Podcast.set_callback(:commit, :after, :pull_all_episodes)
  end

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

  context 'catching exceptions' do
    before do
      stub_request(:head, /https:\/\/traffic.megaphone.fm/).to_return({ status: 200, body: "", headers: {} })
    end

    it "handles Net::OpenTimeout" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(Net::OpenTimeout)
      described_class.new(podcast).call(limit: 2)
      podcast.reload
      expect(podcast.status_notice).to include("Unreachable:")
    end

    it "handles Errno::ECONNREFUSED" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(Errno::ECONNREFUSED)
      described_class.new(podcast).call(limit: 2)
      podcast.reload
      expect(podcast.status_notice).to include("Unreachable:")
    end

    it "handles Errno::EHOSTUNREACH" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(Errno::EHOSTUNREACH)
      described_class.new(podcast).call(limit: 2)
      podcast.reload
      expect(podcast.status_notice).to include("Unreachable:")
    end

    it "handles SocketError" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(SocketError)
      described_class.new(podcast).call(limit: 2)
      podcast.reload
      expect(podcast.status_notice).to include("Unreachable:")
    end

    xit "handles HTTParty::RedirectionTooDeep" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(HTTParty::RedirectionTooDeep)
      described_class.new(podcast).call(limit: 2)
      podcast.reload
      expect(podcast.status_notice).to include("Unreachable:")
    end

    it "handles RSS::NotWellFormedError" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(RSS::NotWellFormedError)
      described_class.new(podcast).call(limit: 2)
      podcast.reload
      expect(podcast.status_notice).to include("Rss couldn't be parsed")
    end
  end
end

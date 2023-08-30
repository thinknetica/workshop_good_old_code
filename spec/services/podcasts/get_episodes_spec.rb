require "rails_helper"

vcr_options = {
  cassette_name: "se_daily_rss_feed",
  allow_playback_repeats: "true",
  record: :new_episodes
}

RSpec.describe Podcasts::GetEpisodes, vcr: vcr_options do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }

  let(:feed_path) { "../../support/fixtures/se_daily_rss_feed.rss" }
  let(:feed) { File.read(File.join(File.dirname(__FILE__), feed_path)) }

  let(:unpodcast_rss) { "http://podcast.example.com/podcast" }

  # concerning!
  before do
    Podcast.skip_callback :commit, :after, :pull_all_episodes
  end

  # concerning!
  after do
    Podcast.set_callback :commit, :after, :pull_all_episodes
  end

  it "fetches episodes" do
    expect {
      described_class.new(podcast).call
    }.to change(podcast.podcast_episodes, :count)
  end

  it "fetches correct episodes" do
    expect(podcast.podcast_episodes.find_by(title: "Modern Coding Superpowers with Varun Mohan").present?).to be false
    described_class.new(podcast).call(limit: 2)
    expect(podcast.podcast_episodes.find_by(title: "Modern Coding Superpowers with Varun Mohan")).to be_a(PodcastEpisode)
  end

  it "handles errors" do
    allow(HTTParty).to receive(:get).with(feed_url).and_raise(Errno::ECONNREFUSED)
    described_class.new(podcast).call(limit: 2)
    podcast.reload
    expect(podcast.status_notice).to include("Unreachable")
  end

  context 'when feed items enclosure_url is reachable' do
    it 'checks that podcast_episode.reachable is true' do
      stub_request(:head, /https:\/\/traffic.megaphone.fm/).to_return({ status: 200 })
      described_class.new(podcast).call
      expect(podcast.podcast_episodes.first.reachable).to be_truthy
    end
  end

  context 'when feed items enclosure_url is unreachable' do
    it 'checks that podcast_episode.reachable is false' do
      stub_request(:head, /https:\/\/traffic.megaphone.fm/).to_return({ status: 404 })
      described_class.new(podcast).call
      expect(podcast.podcast_episodes.first.reachable).to be_falsey
    end
  end

  context 'when limit is specified in .call' do
    it 'fetches limited max episodes count by default limit' do
      described_class.new(podcast).call
      expect(podcast.podcast_episodes.count).to eq 100
    end

    it 'fetches specified count by limit' do
      described_class.new(podcast).call(limit: 10)
      expect(podcast.podcast_episodes.count).to eq 10
    end
  end
end

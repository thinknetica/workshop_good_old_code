require "rails_helper"

vcr_options = {
  cassette_name: "se_daily_rss_feed",
  allow_playback_repeats: "true",
}

RSpec.describe Podcasts::GetEpisodes, vcr: vcr_options do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }
  let(:head_response) { { status: 200, body: "", headers: {} } }

  let(:feed_path) { "../../support/fixtures/se_daily_rss_feed.rss" }
  let(:feed) { File.read(File.join(File.dirname(__FILE__), feed_path)) }

  let(:unpodcast_rss) { "http://podcast.example.com/podcast" }

  # concerning!
  before do
    stub_request(:get, feed_url).to_return(body: feed, headers: { 'Content-Type' => 'application/rss+xml' })
    stub_request(:head, /https:\/\/traffic.megaphone.fm/).to_return(head_response)
    Podcast.skip_callback :commit, :after, :pull_all_episodes
  end

  # concerning!
  after do
    Podcast.set_callback :commit, :after, :pull_all_episodes
  end

  it "fetches episodes" do
    expect { described_class.new(podcast).call }.to change(podcast.podcast_episodes, :count)
  end

  it "fetches correct episodes" do
    aggregate_failures do
      expect(podcast.podcast_episodes.first).not_to be_present
      described_class.new(podcast).call(limit: 1)
      expect(podcast.podcast_episodes.first).to be_a(PodcastEpisode)
    end
  end

  it "handles errors" do
    allow(HTTParty).to receive(:get).with(feed_url).and_raise(Errno::ECONNREFUSED)
    described_class.new(podcast).call(limit: 1)
    podcast.reload
    expect(podcast.status_notice).to include("Unreachable")
  end

  context 'when episode is unreachable' do
    let(:head_response) { { status: 404, body: "", headers: {} } }

    it 'set reachable attr as true' do
      described_class.new(podcast).call(limit: 1)
      expect(podcast.podcast_episodes.first.reachable).to be_falsey
    end
  end
end

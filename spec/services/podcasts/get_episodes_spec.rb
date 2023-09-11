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

  context "with Result object" do
    let(:result) { described_class.new(podcast).call }

    it "returns success" do
      expect(result.success).to be_truthy
      expect(result.error).to be_blank
    end

    it "returns episodes count" do
      expect(result.new_episodes_count).to be_integer
      expect(result.new_episodes_count).to eq 100
    end

    it "returns error" do
      Result = Struct.new(:success, :podcast, :feed_size, :new_episodes_count, :error, keyword_init: true)
      allow_any_instance_of(Podcasts::GetEpisodes).to receive(:call).and_return(Result.new(success: false, error: 'error text'))

      expect(result.success).to be_falsey
      expect(result.error).to eq 'error text'
    end
  end
end

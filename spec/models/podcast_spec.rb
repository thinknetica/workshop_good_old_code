require 'rails_helper'

RSpec.describe Podcast, type: :model do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }

  let(:feed_path) { "../support/fixtures/se_daily_rss_feed.rss" }
  let(:feed) { File.read(File.join(File.dirname(__FILE__), feed_path)) }

  it "fetches episodes" do
    expect(podcast.podcast_episodes).not_to be_empty
  end

  it "fetches correct episodes" do
    expect(podcast.podcast_episodes.find_by(title: "Engineering Insights with Christina Forney")).to be_a(PodcastEpisode)
  end

  # webmock
  # stub_request(:get, "www.example.com").to_return(body: "abc", headers: { "Content-Type" => "application/rss+xml" })
  it "fetches episodes with webmock" do
  end

  # webmock
  it "fetches correct episodes with webmock" do
  end

  # vcr
  # VCR.use_cassette("name", re_record_interval: 1.day) { }
  it "fetches episodes with vcr" do
  end

  # vcr + rspec metadata
  # vcr: { cassette_name: "se_daily_rss_feed", re_record_interval: 1.day }
  it "fetches correct episode with vcr" do
  end

  # stub HTTParty
  xit "fetches correct episodes" do
    feed_obj = double("HTTParty::Response", body: feed)
    allow(HTTParty).to receive(:get).and_return(feed_obj)
  end
end

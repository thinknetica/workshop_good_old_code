require 'rails_helper'

RSpec.describe Podcast, type: :model do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }

  let(:feed_path) { "../support/fixtures/se_daily_rss_feed.rss" }
  let(:feed) { File.read(File.join(File.dirname(__FILE__), feed_path)) }

  # concerning!
  it "is valid" do
    allow_any_instance_of(Podcasts::GetEpisodes).to receive(:call)
    expect(podcast.valid?).to be true
  end

  it "calls Podcasts::GetEpisodes" do
    get_eps = instance_spy(Podcasts::GetEpisodes, call: 1)
    allow(Podcasts::GetEpisodes).to receive(:new).and_return(get_eps)
    podcast
    expect(get_eps).to have_received(:call)
  end

  # it "fetches episodes" do
  #   expect(podcast.podcast_episodes).not_to be_empty
  # end

  # it "fetches correct episodes" do
  #   expect(podcast.podcast_episodes.find_by(title: "Engineering Insights with Christina Forney")).to be_a(PodcastEpisode)
  # end

  # webmock
  # stub_request(:get, "www.example.com").to_return(body: "abc", headers: { "Content-Type" => "application/rss+xml" })
  # it "fetches episodes with webmock" do
  #   stub_request(:get, feed_url).to_return(body: feed, headers: { "Content-Type" => "application/rss+xml" })
  #   expect(podcast.podcast_episodes).not_to be_empty
  # end

  # # webmock
  # it "fetches correct episodes with webmock" do
  #   stub_request(:get, feed_url).to_return(body: feed, headers: { "Content-Type" => "application/rss+xml" })
  #   expect(podcast.podcast_episodes.find_by(title: "Engineering Insights with Christina Forney")).to be_a(PodcastEpisode)
  # end

  # # vcr
  # # VCR.use_cassette("name", re_record_interval: 1.day) { }
  # it "fetches episodes with vcr" do
  #   VCR.use_cassette("se_daily_rss_feed", re_record_interval: 1.day) do
  #     expect(podcast.podcast_episodes).not_to be_empty
  #   end
  # end

  # # vcr + rspec metadata
  # # vcr: { cassette_name: "se_daily_rss_feed", re_record_interval: 1.day }
  # it "fetches correct episode with vcr", vcr: { cassette_name: "se_daily_rss_feed", re_record_interval: 1.day } do
  #   expect(podcast.podcast_episodes.find_by(title: "Engineering Insights with Christina Forney")).to be_a(PodcastEpisode)
  # end

  # # stub HTTParty
  # it "fetches correct episodes" do
  #   feed_obj = double("HTTParty::Response", body: feed)
  #   allow(HTTParty).to receive(:get).and_return(feed_obj)
  #   expect(podcast.podcast_episodes.find_by(title: "Engineering Insights with Christina Forney")).to be_a(PodcastEpisode)
  # end

  # it "handles errors" do
  #   skip "not implemented"
  #   allow(HTTParty).to receive(:get).with(feed_url).and_raise(Errno::ECONNREFUSED)
  #   expect(podcast.status_notice).to include("Unreachable")
  # end
end

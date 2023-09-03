require 'rails_helper'

vcr_options = {
  cassette_name: "se_daily_rss_feed",
  allow_playback_repeats: "true"
}

RSpec.describe Podcast, type: :model, vcr: vcr_options do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url, description: 'Thank you podcast') }
  let(:podcast_with_lang) { create(:podcast, feed_url: feed_url, language: 'en', description: 'Thank you podcast') }

  let(:feed_path) { "../support/fixtures/se_daily_rss_feed.rss" }
  let(:feed) { File.read(File.join(File.dirname(__FILE__), feed_path)) }

  it "is valid" do
    expect(podcast.valid?).to be true
  end

  describe '#detect_language' do
    describe 'showing podcast\'s language' do
      context 'when language is not present' do
        it 'detects and shows language' do
          expect(podcast.detect_language).to eq :en
        end
      end

      context 'when language is present' do
        it 'only shows language without further detection' do
          expect(podcast_with_lang.detect_language).to eq :en
        end
      end
    end
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

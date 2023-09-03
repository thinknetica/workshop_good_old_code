require "rails_helper"

vcr_options = {
  cassette_name: "se_daily_rss_feed",
  allow_playback_repeats: "true",
}

RSpec.describe Podcasts::GetFeed, vcr: vcr_options do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }

  it 'returns a feed for podcast' do
    expect(described_class.new(podcast).call).to be_present
  end

  context 'catching exceptions' do
    it "handles Net::OpenTimeout" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(Net::OpenTimeout)
      expect(described_class.new(podcast).call).to be_nil
      expect(podcast.reload.status_notice).to include("Unreachable:")
    end

    it "handles Errno::ECONNREFUSED" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(Errno::ECONNREFUSED)
      expect(described_class.new(podcast).call).to be_nil
      expect(podcast.reload.status_notice).to include("Unreachable:")
    end

    it "handles Errno::EHOSTUNREACH" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(Errno::EHOSTUNREACH)
      expect(described_class.new(podcast).call).to be_nil
      expect(podcast.reload.status_notice).to include("Unreachable:")
    end

    it "handles SocketError" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(SocketError)
      expect(described_class.new(podcast).call).to be_nil
      expect(podcast.reload.status_notice).to include("Unreachable:")
    end

    xit "handles HTTParty::RedirectionTooDeep" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(HTTParty::RedirectionTooDeep)
      expect(described_class.new(podcast).call).to be_nil
      expect(podcast.reload.status_notice).to include("Unreachable:")
    end

    it "handles RSS::NotWellFormedError" do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(RSS::NotWellFormedError)
      expect(described_class.new(podcast).call).to be_nil
      expect(podcast.reload.status_notice).to include("Rss couldn't be parsed")
    end
  end
end

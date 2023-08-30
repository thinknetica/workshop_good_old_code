require "rails_helper"

RSpec.describe Podcasts::DetectLanguage do
  let!(:podcast) { create :podcast, feed_url: feed_url }
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }

  let(:feed_path) { "../../support/fixtures/se_daily_rss_feed.rss" }
  let(:feed) { File.read(File.join(File.dirname(__FILE__), feed_path)) }

  before { stub_request(:get, feed_url).to_return(status: 200, body: feed, headers: {}) }

  describe '.call' do
    it 'returns language' do
      expect(described_class.call(podcast)).to eq(:en)
    end

    it 'change podcast attrs' do
      expect{ described_class.call(podcast) }.to change(podcast, :language)
                                             .and change(podcast, :description)
    end

    it 'raise error' do
      allow(HTTParty).to receive(:get).with(feed_url).and_raise(StandardError)
      expect(described_class.call(podcast)).to eq('StandardError')
    end
  end
end

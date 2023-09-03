require 'rails_helper'

RSpec.describe Podcast, type: :model do
  describe "#detect_language" do
    let(:podcast) { create(:podcast, description: 'Let me introduce myself') }

    it 'detects language' do
      expect(podcast.language).to be_nil
      expect(podcast.detect_language).to eq('en')
    end
  end

  describe '#detect_description' do
    let(:podcast) { create(:podcast, description: nil) }

    let(:feed_path) { "../support/fixtures/se_daily_rss_feed.rss" }
    let(:feed) { File.read(File.join(File.dirname(__FILE__), feed_path)) }
    let(:feed_rss) { RSS::Parser.parse(feed, false) }

    it 'detects description' do
      expect(podcast.description).to be_nil
      allow_any_instance_of(Podcasts::GetFeed).to receive(:call).and_return(feed_rss)
      expect(podcast.detect_description).to eq(RSS::Parser.parse(feed, false).channel.description)
    end
  end
end

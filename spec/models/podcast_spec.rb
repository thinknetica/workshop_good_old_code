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
end

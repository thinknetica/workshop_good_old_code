require 'rails_helper'

RSpec.describe Podcast, type: :model do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }

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

require 'rails_helper'

RSpec.describe Podcast, type: :model do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }
  let(:podcast) { create(:podcast, feed_url: feed_url) }

  it "fetches episodes" do
    expect(podcast.podcast_episodes).not_to be_empty
  end

  it "fetches correct episodes" do
    expect(podcast.podcast_episodes.find_by(title: "Engineering Insights with Christina Forney")).to be_a(PodcastEpisode)
  end
end

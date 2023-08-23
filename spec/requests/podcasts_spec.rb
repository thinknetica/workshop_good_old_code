require 'rails_helper'

vcr_options = {
  cassette_name: "se_daily_rss_feed",
  allow_playback_repeats: "true",
}

RSpec.describe "Podcasts", vcr: vcr_options, type: :request do
  let(:feed_url) { "http://softwareengineeringdaily.com/feed/podcast/" }

  describe "GET /index" do
    before do
      Podcast.skip_callback :commit, :after, :pull_all_episodes
    end

    after do
      Podcast.set_callback :commit, :after, :pull_all_episodes
    end

    it "renders successfully" do
      get podcasts_path
      expect(response).to have_http_status(:ok)
    end

    it "renders with podcasts" do
      podcasts = create_list(:podcast, 5)
      get podcasts_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(podcasts.first.title)
    end
  end

  describe "POST /create" do
    let(:podcast_params) do
      {
        title: "Software Radio",
        slug: "sedaily",
        feed_url: feed_url
      }
    end

    it "creates a podcast" do
      get_eps = instance_double(Podcasts::GetEpisodes, call: 1)
      allow(Podcasts::GetEpisodes).to receive(:new).and_return(get_eps)
      expect do
        post podcasts_path, params: { podcast: podcast_params }
      end.to change(Podcast, :count).by(1)
    end

    it "create episodes" do
      post podcasts_path, params: { podcast: podcast_params }
      podcast = Podcast.find_by(feed_url: feed_url)
      expect(podcast.podcast_episodes).not_to be_empty
    end
  end

  describe "PUT /update" do
    let(:podcast) { create(:podcast, title: "Software Radio", slug: "sedaily", feed_url: feed_url) }
    let(:new_title) { "Super Software Radio" }
    let(:podcast_params) do
      {
        title: new_title,
        slug: "sedaily",
        feed_url: feed_url
      }
    end
    let(:get_eps) { instance_spy(Podcasts::GetEpisodes, call: 1) }

    before do
      allow(Podcasts::GetEpisodes).to receive(:new).and_return(get_eps)
    end

    it "updates a podcast" do
      patch podcast_path(podcast.id), params: { podcast: podcast_params }
      podcast.reload
      expect(podcast.title).to eq(new_title)
    end

    it "calls Podcasts::GetEpisodes" do
      patch podcast_path(podcast.id), params: { podcast: podcast_params }
      expect(Podcasts::GetEpisodes).to have_received(:new).with(podcast).twice
      expect(get_eps).to have_received(:call).twice
    end
  end

  describe "PATCH /fetch" do
    # actually fetching/parsing
    it "fetches a podcast" do
      Podcast.skip_callback :commit, :after, :pull_all_episodes
      podcast = create(:podcast, feed_url: feed_url)
      Podcast.set_callback :commit, :after, :pull_all_episodes

      patch fetch_podcast_path(podcast.id)

      expect(podcast.podcast_episodes).not_to be_empty
      expect(podcast.podcast_episodes.find_by(title: "Engineering Insights with Christina Forney")).to be_a(PodcastEpisode)
    end

    # stubbed call / mock
    it "calls Podcasts::GetEpisodes" do
      get_eps = instance_spy(Podcasts::GetEpisodes, call: 1)
      allow(Podcasts::GetEpisodes).to receive(:new).and_return(get_eps)

      podcast = create(:podcast, feed_url: feed_url)

      patch fetch_podcast_path(podcast.id)

      expect(Podcasts::GetEpisodes).to have_received(:new).with(podcast).twice
      expect(get_eps).to have_received(:call).at_least(2).times
    end

    it "sets successful flash[:notice]" do
      skip "not implemented"

      # result = instance_double(Podcasts::GetEpisodes::Result, success: true, feed_size: 10, new_episodes_count: 5)
      # get_eps = instance_double(Podcasts::GetEpisodes, call: result)
      # allow(Podcasts::GetEpisodes).to receive(:new).and_return(get_eps)

      patch fetch_podcast_path(podcast.id)
      follow_redirect!
      expect(response.body).to include("Fetched 5 episodes, feed size - 10")
    end

    it "sets flash[:error] when not successful" do
      skip "not implemented"

      # result = instance_double(Podcasts::GetEpisodes::Result, success: false, error: "unreachable")
      # get_eps = instance_double(Podcasts::GetEpisodes, call: result)
      # allow(Podcasts::GetEpisodes).to receive(:new).and_return(get_eps)

      patch fetch_podcast_path(podcast.id)
      follow_redirect!
      expect(response.body).to include("Error while fetching: unreachable")
    end
  end
end

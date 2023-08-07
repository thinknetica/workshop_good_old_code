class PodcastsController < ApplicationController
  def index
    @podcasts = Podcast.order("created_at DESC")
  end

  def show
    @podcast = Podcast.includes(:podcast_episodes).find(params[:id])
  end

  def new
    @podcast = Podcast.new
  end

  def create
    @podcast = Podcast.create(podcast_params)
    if @podcast.persisted?
      Podcasts::GetEpisodes.call(@podcast)
      flash[:notice] = "Podcast saved"
      redirect_to podcasts_path
    else
      render :new
    end
  end

  def edit
    @podcast = Podcast.find(params[:id])
  end

  def update
    @podcast = Podcast.find(params[:id])
    success = @podcast.update(podcast_params)
    if success
      Podcasts::GetEpisodes.call(@podcast)
      flash[:notice] = "Saved successfully"
      redirect_to podcasts_path
    else
      flash[:error] = "Not saved"
      render :edit
    end
  end

  def fetch
    @podcast = Podcast.find(params[:id])
    result = Podcasts::GetEpisodes.call(@podcast)
    if result.success
      flash[:notice] = "Fetched #{result.new_episodes_count} episodes, feed size - #{result.feed_size}"
    else
      flash[:error] = "Error while fetching: #{result.error}"
    end
    redirect_to podcasts_url
  end

  private

  def podcast_params
    params.require(:podcast).permit(:feed_url, :title, :slug)
  end
end

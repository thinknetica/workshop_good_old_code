module Podcasts
  class GetEpisodes
    Result = Struct.new(:success, :podcast, :feed_size, :new_episodes_count, :error, keyword_init: true)

    def initialize(podcast)
      @podcast = podcast
    end

    def self.call(...)
      new(...).call
    end

    def call(limit: 100)
      episodes_were = podcast.podcast_episodes.count
      feed = Podcasts::GetFeed.call(podcast)
      feed.items.each do |item|
        unless PodcastEpisode.find_by(media_url: item.enclosure.url).presence
          create_podcast_episode(item)
        end
      end
      new_episodes_count = podcast.podcast_episodes.count - episodes_were
      Result.new(success: true, podcast: podcast, feed_size: feed.items.size, new_episodes_count: new_episodes_count)
    rescue StandardError => e
      Result.new(success: false, error: e, podcast: podcast)
    end

    private

    attr_reader :podcast

    def enclosure_url_reachable(url)
      HTTParty.head(url).code == 200
    end

    def create_podcast_episode(item)
      ep            = PodcastEpisode.new
      ep.title      = item.title
      ep.podcast_id = podcast.id
      ep.slug       = item.title.downcase.gsub(/[^0-9a-z ]/i, "").gsub(" ", "-")
      ep.guid       = item.guid
      ep.media_url  = item.enclosure.url
      # ep.reachable  = enclosure_url_reachable(item.enclosure.url)
      begin
        ep.published_at = item.pubDate.to_date
      rescue
        puts "not valid date"
      end
      ep.save!
    end
  end
end

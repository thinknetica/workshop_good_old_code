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
      rss = HTTParty.get(podcast.feed_url).body.to_s
      feed = RSS::Parser.parse(rss, false)
      feed.items[0...limit.abs].each { |item| create_podcast_episode(item) }
      new_episodes_count = podcast.podcast_episodes.count - episodes_were
      Result.new(success: true, podcast: podcast, feed_size: feed.items.size, new_episodes_count: new_episodes_count)
    rescue Net::OpenTimeout, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError, HTTParty::RedirectionTooDeep => e
      podcast.update_column(:status_notice, "Unreachable: #{e}")
      Result.new(success: false, error: e, podcast: podcast)
    rescue RSS::NotWellFormedError
      podcast.update_column(:status_notice, "Rss couldn't be parsed")
      Result.new(success: false, error: e, podcast: podcast)
    end

    private

    attr_reader :podcast

    def create_podcast_episode(feed_item)
      PodcastEpisode.find_or_create_by(media_url: feed_item.enclosure.url) do |pe|
        pe.title = feed_item.title
        pe.podcast_id = podcast.id
        pe.slug = feed_item.title.downcase.gsub(/[^0-9a-z ]/i, "").gsub(" ", "-")
        pe.guid = feed_item.guid
        pe.media_url = feed_item.enclosure.url
        pe.reachable = enclosure_url_reachable(feed_item.enclosure.url)
        pe.published_at = feed_item.pubDate&.to_date
      end
    end

    def enclosure_url_reachable(url)
      HTTParty.head(url).code == 200
    end
  end
end

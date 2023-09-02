# Net::OpenTimeout, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError, HTTParty::RedirectionTooDeep => e
# RSS::NotWellFormedError
module Podcasts
  class GetEpisodes
    def initialize(podcast)
      @podcast = podcast
    end

    def self.call(...)
      new(...).call
    end

    def call(limit: 100)
      rss = HTTParty.get(podcast.feed_url).body.to_s
      feed = RSS::Parser.parse(rss, false)
      feed.items[0...limit.abs].each { |item| create_podcast_episode(item) }
      feed.items.size
    rescue Net::OpenTimeout, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError, HTTParty::RedirectionTooDeep => e
      podcast.update_column(:status_notice, "Unreachable: #{e}")
    rescue RSS::NotWellFormedError
      podcast.update_column(:status_notice, "Rss couldn't be parsed")
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

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
      feed.items.each do |item|
        unless PodcastEpisode.find_by(media_url: item.enclosure.url).presence
          ep = PodcastEpisode.new
          ep.title = item.title
          ep.podcast_id = podcast.id
          ep.slug = item.title.downcase.gsub(/[^0-9a-z ]/i, "").gsub(" ", "-")
          ep.guid = item.guid
          ep.media_url = item.enclosure.url
          # ep.reachable = enclosure_url_reachable(item.enclosure.url)
          begin
            ep.published_at = item.pubDate.to_date
          rescue
            puts "not valid date"
          end
          ep.save!
        end
      end
      feed.items.size
    rescue Net::OpenTimeout, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError, HTTParty::RedirectionTooDeep => e
      podcast.update_column(:status_notice, "Unreachable #{e}")
    rescue RSS::NotWellFormedError
      podcast.update_column(:status_notice, "Rss couldn't be parsed")
    end

    private

    attr_reader :podcast

    def enclosure_url_reachable(url)
      HTTParty.head(url).code == 200
    end
  end
end

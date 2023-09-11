module Podcasts
  class GetFeed
    Result = Struct.new(:success, :feed, :error, keyword_init: true)

    def initialize(podcast)
      @podcast = podcast
    end

    def self.call(...)
      new(...).call
    end

    def call
      rss = HTTParty.get(podcast.feed_url).body.to_s
      feed = RSS::Parser.parse(rss, false)
      Result.new(success: true, feed: feed)
    rescue Net::OpenTimeout, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError, HTTParty::RedirectionTooDeep => e
      podcast.update_column(:status_notice, "Unreachable #{e}")
      Result.new(success: false, error: e)
    rescue RSS::NotWellFormedError
      podcast.update_column(:status_notice, "Rss couldn't be parsed")
      Result.new(success: false, error: e)
    end

    private

    attr_reader :podcast
  end
end
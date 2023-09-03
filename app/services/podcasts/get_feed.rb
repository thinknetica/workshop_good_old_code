module Podcasts
  class GetFeed
    def initialize(podcast)
      @podcast = podcast
    end

    def self.call(...)
      new(...).call
    end

    def call
      rss = HTTParty.get(podcast.feed_url).body.to_s
      RSS::Parser.parse(rss, false)
    rescue Net::OpenTimeout, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError, HTTParty::RedirectionTooDeep => e
      podcast.update_column(:status_notice, "Unreachable: #{e}")
      nil
    rescue RSS::NotWellFormedError
      podcast.update_column(:status_notice, "Rss couldn't be parsed")
      nil
    end

    private

    attr_reader :podcast
  end
end

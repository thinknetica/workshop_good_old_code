#  Net::OpenTimeout, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError, HTTParty::RedirectionTooDeep => e
# RSS::NotWellFormedError
module Podcasts
  class GetEpisodes
    def initialize(podcast)
      @podcast = podcast
    end

    def call(limit: 100)
    end

    private

    attr_reader :podcast

    # def enclosure_url_reachable(url)
    #   HTTParty.head(url).code == 200
    # end
  end
end

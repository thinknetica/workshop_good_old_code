module Podcasts
  class DetectLanguage
    Result = Struct.new(:success, :podcast, :feed_size, :new_episodes_count, :error, keyword_init: true)

    def initialize(podcast,
                   http_client = HTTParty, rss_parser = RSS::Parser, identifier = CLD3::NNetLanguageIdentifier)
      @podcast = podcast
      @http_client = http_client
      @rss_parser = rss_parser
      @identifier = identifier
    end

    def self.call(...)
      new(...).call
    end

    def call
      rss = http_client.get(@podcast.feed_url).body.to_s
      feed = rss_parser.parse(rss, false)
      description = feed.channel.description
      res = identifier.new(0, 1000).find_language(description)
      # DetectLanguage.detect(description)
      @podcast.update(language: res.language, description: description)
      res.language
    rescue StandardError => e
      p e.message
    end

    private

    attr_reader :http_client, :rss_parser, :identifier
  end
end

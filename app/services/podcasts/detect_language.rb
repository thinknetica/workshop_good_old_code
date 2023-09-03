module Podcasts
  class DetectLanguage
    def initialize(podcast)
      @podcast = podcast
    end

    def self.call(...)
      new(...).call
    end

    def call
      CLD3::NNetLanguageIdentifier.new(0, 1000).find_language(podcast.description)&.language
    end

    private

    attr_reader :podcast
  end
end
class Podcast < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :feed_url, presence: true, uniqueness: true

  has_many :podcast_episodes, dependent: :delete_all

  def detect_language
    rss = HTTParty.get(feed_url).body.to_s
    feed = RSS::Parser.parse(rss, false)
    self.description = feed.channel.description
    res = CLD3::NNetLanguageIdentifier.new(0, 1000).find_language(description)
    # DetectLanguage.detect(description)
    self.update(language: res.language)
    res.language
  rescue StandardError => e
    p e
  end
end

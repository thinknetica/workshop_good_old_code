class Podcast < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :feed_url, presence: true, uniqueness: true

  has_many :podcast_episodes, dependent: :delete_all

  after_commit :pull_all_episodes

  private

  def pull_all_episodes
    rss = HTTParty.get(feed_url).body.to_s
    feed = RSS::Parser.parse(rss, false)
    feed.items.each do |item|
      unless PodcastEpisode.find_by(media_url: item.enclosure.url).presence
        ep = PodcastEpisode.new
        ep.title = item.title
        ep.podcast_id = id
        ep.slug = item.title.downcase.gsub(/[^0-9a-z ]/i, "").gsub(" ", "-")
        ep.guid = item.guid
        ep.media_url = item.enclosure.url
        begin
          ep.published_at = item.pubDate.to_date
        rescue
          puts "not valid date"
        end
        ep.save!
      end
    end
    feed.items.size
  end
end

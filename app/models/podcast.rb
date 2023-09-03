class Podcast < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :feed_url, presence: true, uniqueness: true

  has_many :podcast_episodes, dependent: :delete_all

  def detect_language
    update(language: Podcasts::DetectLanguage.new(self).call)
    language
  end

  def detect_description
    update(description: Podcasts::GetFeed.new(self).call&.channel&.description)
    description
  end
end

class Podcast < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :feed_url, presence: true, uniqueness: true

  has_many :podcast_episodes, dependent: :delete_all

  def detect_language
    Podcasts::DetectLanguage.call(self)
  end
end

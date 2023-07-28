class PodcastEpisode < ApplicationRecord
  belongs_to :podcast

  validates :guid, presence: true, uniqueness: true
  validates :media_url, presence: true, uniqueness: true
  validates :slug, presence: true
  validates :title, presence: true
end

class Podcast < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :feed_url, presence: true, uniqueness: true

  has_many :podcast_episodes, dependent: :delete_all

  after_commit :pull_all_episodes

  private

  def pull_all_episodes
    Podcasts::GetEpisodes.new(self).call
  end
end

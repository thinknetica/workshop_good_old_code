class CreatePodcastEpisodes < ActiveRecord::Migration[7.0]
  def change
    create_table :podcast_episodes do |t|
      t.references :podcast, foreign_key: true
      t.string :title, null: false
      t.text   :summary
      t.string :media_url, null: false, index: { unique: true }
      t.string :image
      t.datetime :published_at
      t.string :slug, null: false
      t.string :guid, null: false, index: { unique: true }
      t.boolean :reachable

      t.timestamps
    end
  end
end

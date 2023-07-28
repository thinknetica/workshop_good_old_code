class CreatePodcasts < ActiveRecord::Migration[7.0]
  def change
    create_table :podcasts do |t|
      t.string :title, null: false
      t.text   :description
      t.string :feed_url, null: false, unique: true
      t.string :image
      t.string :slug, null: false, index: { unique: true }
      t.text :status_notice, default: ""

      t.timestamps
    end
  end
end

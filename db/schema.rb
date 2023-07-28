# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_07_28_092048) do
  create_table "podcast_episodes", force: :cascade do |t|
    t.integer "podcast_id"
    t.string "title", null: false
    t.text "summary"
    t.string "media_url", null: false
    t.string "image"
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "guid", null: false
    t.boolean "reachable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guid"], name: "index_podcast_episodes_on_guid", unique: true
    t.index ["media_url"], name: "index_podcast_episodes_on_media_url", unique: true
    t.index ["podcast_id"], name: "index_podcast_episodes_on_podcast_id"
  end

  create_table "podcasts", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "feed_url", null: false
    t.string "image"
    t.string "slug", null: false
    t.text "status_notice", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_podcasts_on_slug", unique: true
  end

  add_foreign_key "podcast_episodes", "podcasts"
end

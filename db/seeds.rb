# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

path = Rails.root.join("podcasts.csv")
table = CSV.read(path, headers: true)

table.each do |row|
  Podcast.find_or_create_by!(feed_url: row["url"].strip) do |pod|
    pod.title = row["title"].strip
    pod.slug = pod.title.parameterize # e.g. "Remote Ruby" => "remote-ruby"
  end
end

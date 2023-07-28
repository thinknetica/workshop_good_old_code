FactoryBot.define do
  sequence(:podcast_slug) { |n| "slug-#{n}" }
  sequence(:podcast_title) { |n| "#{Faker::Beer.name }-#{n}" }

  factory :podcast do
    title           { generate(:podcast_title) }
    description     { Faker::Hipster.paragraph(sentence_count: 1) }
    slug            { generate(:podcast_slug) }
    feed_url        { Faker::Internet.url }
  end
end

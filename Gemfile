source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "cld3", "~> 3.5" # Ruby interface for Compact Language Detector v3

# gem "detect_language", "~> 1.1.2"

gem "httparty", "~> 0.21"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.6"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 1.4"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

gem "rss", "~> 0.2.9"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "factory_bot_rails", "~> 6.2"
  gem "faker", "~> 2.22"
  gem "rspec-rails", "~> 6.0.3"
  gem "vcr", "~> 6.2.0" # Record your test suite's HTTP interactions and replay them during future test runs for fast, deterministic, accurate tests
  gem "webmock", "~> 3.18.1", require: false # WebMock allows stubbing HTTP requests and setting expectations on HTTP requests
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end


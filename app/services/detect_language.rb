class DetectLanguage
  def initialize(text)
    @text = text
  end

  def self.call(...)
    new(...).call
  end

  def call
    raise 'The text you want to detect its language is not specified' if text.nil?
    CLD3::NNetLanguageIdentifier.new(0, 1000).find_language(text).language
  end

  private

  attr_reader :text
end
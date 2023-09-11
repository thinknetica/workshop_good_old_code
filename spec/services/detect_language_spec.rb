require "rails_helper"

RSpec.describe DetectLanguage do
  it 'detects podcast\'s language and returns it as symbol' do
    expect(described_class.call('Thank you podcast')).to eq :en
    expect(described_class.call('Merci pour le podcast')).to eq :fr
  end

  it 'raises error if text to detect is not specified' do
    expect{ described_class.call(nil) }.to raise_error(RuntimeError, 'The text you want to detect its language is not specified')
  end
end
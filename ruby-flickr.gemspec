require './lib/ruby-flickr/version'

Gem::Specification.new do |s|
    s.name = 'ruby-flickr'
    s.version = RubyFlickr::VERSION
    s.summary = 'Use FlickRaw gem (or not) to access Flickr API.'
    s.authors = ['Dominick Guzzo']
    s.email = 'dguzzo@gmail.com'
    
    s.files = Dir['lib/**/*.rb', 'vendor/*.rb']
    
    s.add_dependency 'flickraw'
    
    s.add_development_dependency 'rspec'
    s.add_development_dependency 'pry'
    s.add_development_dependency 'pry-nav'
end

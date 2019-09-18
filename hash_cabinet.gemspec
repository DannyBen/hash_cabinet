lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'hash_cabinet'
  s.version     = '0.1.0'
  s.date        = Date.today.to_s
  s.summary     = "Key-object file database with hash-like access"
  s.description = "Store objects in a file using hash-like syntax"
  s.authors     = ["Danny Ben Shitrit"]
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*.*']
  s.homepage    = 'https://github.com/dannyben/hash_cabinet'
  s.license     = 'MIT'
  s.required_ruby_version = ">= 2.5.0"
end

require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler'
Bundler.require :default, :development

Dir.mkdir 'tmp' unless Dir.exist? 'tmp'

def create_dummy_db
  cabinet = HashCabinet.new 'tmp/specdb'

  data = {
    'metallica'   => { name: 'Metallica',
      active_since: 1981, active_to: 'Present' },
    'iron-maiden' => { name: 'Iron Maiden',
      active_since: 1975, active_to: 'Present' },
    'pantera'     => { name: 'Pantera',
      active_since: 1981, active_to: 2003 },
  }

  cabinet.replace data
end

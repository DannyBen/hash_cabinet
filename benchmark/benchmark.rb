require 'yaml/store'
require 'pstore'
require 'colsole'
require 'hash_cabinet'
require 'sqlite3'

require './bm'

include Colsole

# Config
repeat = 1000
test_hash_cabinet = true
test_sqlite       = true
test_pstore       = true
test_yaml_store   = false

# Preparations
def sample_object
  { some: 'object', random: rand(1..99_999) }
end

cabinet_file    = 'tmp/hash_cabinet'
pstore_file     = 'tmp/pstore.pstore'
yaml_store_file = 'tmp/store.yml'
sqlite_file     = 'tmp/db.sqlite'

Dir.mkdir 'tmp' unless Dir.exist? 'tmp'

say "!txtgrn!Initializing #{repeat} objects"

if test_hash_cabinet
  puts 'Initializing HashCabinet...'
  cabinet = HashCabinet.new cabinet_file
  cabinet.transaction do |db|
    db.clear
    repeat.times { |i| db["key#{i}"] = sample_object.to_yaml }
  end
end

if test_pstore
  puts 'Initializing Pstore...'
  File.delete pstore_file if File.exist? pstore_file
  pstore = PStore.new(pstore_file)
  pstore.transaction do
    repeat.times { |i| pstore["key#{i}"] = sample_object }
    pstore.commit
  end
end

if test_yaml_store
  puts 'Initializing YAML::Store...'
  File.delete yaml_store_file if File.exist? yaml_store_file
  ystore = YAML::Store.new yaml_store_file
  ystore.transaction do
    repeat.times { |i| ystore["key#{i}"] = sample_object }
    ystore.commit
  end
end

if test_sqlite
  puts 'Initializing SQLite...'
  File.delete sqlite_file if File.exist? sqlite_file
  sqlite = SQLite3::Database.new sqlite_file
  sqlite.results_as_hash = true
  sqlite.execute <<-SQL
    create table data (
      key varchar(30),
      val varchar(30)
    );
  SQL

  repeat.times do |i|
    sqlite.execute 'insert into data values ( ?, ? )', "key#{i}", sample_object.to_yaml
  end
end

bm = BM.new

if test_hash_cabinet
  bm.add('HashCabinet') do |i|
    cabinet["key#{i}"]
  end
end

if test_sqlite
  bm.add('SQLite') do |i|
    sqlite.execute("select * from data where key = 'key#{i}'")
  end
end

if test_pstore
  bm.add('PStore') do |i|
    pstore.transaction { pstore["key#{i}"] }
  end
end

if test_yaml_store
  bm.add('YAML::Store') do |i|
    ystore.transaction { ystore["key#{i}"] }
  end
end

bm.run repeat

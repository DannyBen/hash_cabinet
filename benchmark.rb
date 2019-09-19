require "bundler/inline"
require "yaml/store"
require 'benchmark'
require 'pstore'

gemfile do
  source "https://rubygems.org"
  gem 'hash_cabinet'
  gem "benchmark-memory"
  gem "sqlite3"
end

# Config
repeat = 500
test_hash_cabinet = true
test_sqlite       = true
test_pstore       = true
test_yaml_store   = true

# Preparations
def sample_object
  { some: 'object', random: rand(1..99999) }
end

cabinet_file    = 'tmp/hash_cabinet'
pstore_file     = 'tmp/pstore.pstore'
yaml_store_file = 'tmp/store.yml'
sqlite_file     = 'tmp/db.sqlite'

if test_hash_cabinet
  puts "Initializing HashCabinet..."
  cabinet = HashCabinet.new cabinet_file
  cabinet.transaction do |db|
    db.clear
    repeat.times { |i| db["key#{i}"] = sample_object.to_yaml }
  end
end

if test_pstore 
  puts "Initializing Pstore..."
  File.delete pstore_file if File.exist? pstore_file
  pstore = PStore.new(pstore_file)
  pstore.transaction do
    repeat.times { |i| pstore["key#{i}"] = sample_object }
    pstore.commit
  end
end

if test_yaml_store
  puts "Initializing YAML::Store..."
  File.delete yaml_store_file if File.exist? yaml_store_file
  ystore = YAML::Store.new yaml_store_file
  ystore.transaction do
    repeat.times { |i| ystore["key#{i}"] = sample_object }
    ystore.commit
  end
end

if test_sqlite
  puts "Initializing SQLite..."
  File.delete sqlite_file if File.exist? sqlite_file
  sqlite = SQLite3::Database.new sqlite_file
  sqlite.results_as_hash = true
  rows = sqlite.execute <<-SQL
    create table data (
      key varchar(30),
      val varchar(30)
    );
  SQL

  repeat.times do |i|
    sqlite.execute "insert into data values ( ?, ? )", "key#{i}", sample_object.to_yaml
  end
end

puts "\n\nBenchmark ------------------------------------------------\n\n"
Benchmark.bmbm 12 do |bm|
  if test_hash_cabinet
    bm.report 'HashCabinet' do
      repeat.times { |i| cabinet["key#{i}"] }
    end
  end

  if test_sqlite
    bm.report 'SQLite' do
      repeat.times do |i|
        sqlite.execute( "select * from data where key = 'key#{i}'" )
      end
    end
  end

  if test_pstore
    bm.report 'PStore' do
      repeat.times { |i| pstore.transaction { pstore["key#{i}"] } }
    end
  end

  if test_yaml_store
    bm.report 'YAML::Store' do
      repeat.times { |i| ystore.transaction { ystore["key#{i}"] } }
    end
  end

end

puts "\n\nMemory Benchmark -----------------------------------------\n\n"
Benchmark.memory do |x|
  if test_hash_cabinet
    x.report("HashCabinet") { cabinet['key1'] }
  end

  if test_sqlite
    x.report("SQLite") { sqlite.execute( "select * from data where key = 'key1'" ) }
  end
  
  if test_pstore
    x.report("PStore") { pstore.transaction { pstore["key#1"] } }
  end

  if test_yaml_store
    x.report("YAML::Store") { ystore.transaction { ystore["key1"] } }
  end

  x.compare!
end

Hash Cabinet - File based key-object store
==================================================

[![Gem Version](https://badge.fury.io/rb/hash_cabinet.svg)](https://badge.fury.io/rb/hash_cabinet)
[![Build Status](https://travis-ci.com/DannyBen/hash_cabinet.svg?branch=master)](https://travis-ci.com/DannyBen/hash_cabinet)
[![Maintainability](https://api.codeclimate.com/v1/badges/c69f9676cd8cd5fc33bc/maintainability)](https://codeclimate.com/github/DannyBen/hash_cabinet/maintainability)

---

Hash Cabinet is a file-based, key-object store with hash-like access.


Highlights
--------------------------------------------------

- Tiny library, based on Ruby's built in [SDBM].
- Stores simple values or complex objects through transparent YAML 
  serialization.
- Easy hash-like access: `cabinet['key'] = 'value'`.
- Mirrors most of the native SDBM methods.


Installation
--------------------------------------------------

    $ gem install hash_cabinet



Usage
--------------------------------------------------

```ruby
require 'hash_cabinet'

cabinet = HashCabinet.new 'dbfile'

# Store values
cabinet['some-key'] = 'some-value'
cabinet['another-key'] = { color: 'yellow' }

# Retrieve values
p cabinet['another-key']
#=> {:color=>"yellow", :shape=>"circle"}

# Show all values
p cabinet.to_h
#=> {"some-key"=>"some=value", "another-key"=>{:color=>"yellow"}}

```

Quick Reference
--------------------------------------------------

| Method | Description |
|--------|-------------|
| `cabinet.transaction { ... }`       | Yields the `SDBM` object. (like `SDBM.open`) |
| `cabinet[key]`                      | Returns the value at key |
| `cabinet[key] = value`              | Saves the value at key |
| `cabinet.clear`                     | Deletes all data |
| `cabinet.delete key`                | Deletes a key |
| `cabinet.delete_if { \|k, v\| ... }`| Deletes keys based on the block result |
| `cabinet.each { \|k, v\| ... }`     | Iterates over the data |
| `cabinet.each_key { \|k\| ... }`    | Iterates over the keys |
| `cabinet.each_value { \|v\| ... }`  | Iterates over the values |
| `cabinet.emoty?`                    | Returns true if the database is empty |
| `cabinet.has_key? key`              | Returns true if the key exists | 
| `cabinet.has_value? value`          | Returns true if the value exists | 
| `cabinet.include? key`              | Same as `cabinet.has_key?` |
| `cabinet.key value`                 | Returns the key associated with the value |
| `cabinet.key? key`                  | Same as `cabinet.has_key?` |
| `cabinet.keys`                      | Returns all the keys |
| `cabinet.length`                    | Returns the number of key-value pairs |
| `cabinet.replace data`              | Reset the database with new data |
| `cabinet.select { \|k, v\| ... }`   | Returns a hash based on the block result |
| `cabinet.shift`                     | Removes and returns one key-value pair |
| `cabinet.size`                      | Same as `cabinet.length` |
| `cabinet.to_a`                      | Returns an array of `[key, value]` pairs |
| `cabinet.to_h`                      | Returns a hash with all key-value pairs |
| `cabinet.update data`               | Insert or update new data |
| `cabinet.value? value`              | Returns true if the value is in the database |
| `cabinet.values`                    | Returns an array of all the values |
| `cabinet.values_at key, ...`        | Returns an array of values corresponding to the given keys |


Documentation
--------------------------------------------------

- [Documentation on RubyDoc][docs]



[SDBM]: https://ruby-doc.org/stdlib-2.6.3/libdoc/sdbm/rdoc/SDBM.html
[docs]: https://rubydoc.info/gems/hash_cabinet/HashCabinet

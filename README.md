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
cabinet = HashCabinet.new 'dbfile'

# Store values
cabinet['some-key'] = 'some=value'
cabinet['another-key'] = { color: 'yellow' }

# Retrieve values
p cabinet['another-key']
#=> {:color=>"yellow", :shape=>"circle"}

# Show all values
p cabinet.to_h
#=> {"some-key"=>"some=value", "another-key"=>{:color=>"yellow"}}

```

Documentation
--------------------------------------------------

- [Documentation on RubyDoc][docs]



[SDBM]: https://ruby-doc.org/stdlib-2.6.3/libdoc/sdbm/rdoc/SDBM.html
[docs]: https://rubydoc.info/gems/hash_cabinet/HashCabinet

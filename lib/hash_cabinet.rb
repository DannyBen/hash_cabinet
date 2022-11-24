require 'sdbm'
require 'yaml'

# @!attribute [r] path
#   @return [String] the path to the database file
class HashCabinet
  # Refinements for internal use
  module Refinements
    refine String do
      def from_yaml
        YAML.load self
      end
    end

    refine NilClass do
      def from_yaml
        nil
      end
    end
  end

  using Refinements

  attr_reader :path

  # Initializes a new database file at {path}
  #
  # @param [String] path the path to the database file
  def initialize(path)
    @path = path
  end

  # Yields the +SDBM+ object to the block.
  #
  # @example
  #   cabinet = HashCabinet.new 'filename'
  #
  #   cabinet.transaction do |db|
  #     db.clear
  #   end
  #
  # @note
  #   Under most circumstances, this method should not be used directly,
  #   as it is used by all other methods.
  #
  # @yieldparam [SDBM] db the {SDBM} instance
  def transaction(&block)
    SDBM.open path, &block
  end

  # @return [Object] the value in the database associated with the given +key+.
  def [](key)
    transaction { |db| db[key.to_s].from_yaml }
  end

  # Inserts or updates a value in the database with the given key as an index.
  def []=(key, value)
    transaction { |db| db[key.to_s] = value.to_yaml }
  end

  # Deletes all key-value pairs from the database.
  def clear
    transaction(&:clear)
  end

  # Deletes the given `key` from the database.
  def delete(key)
    transaction { |db| db.delete key.to_s }
  end

  # Iterates over the key-value pairs in the database, deleting those for
  # which the block returns true.
  #
  # @example Delete all records with +age < 18+.
  #   cabinet = HashCabinet.new 'filename'
  #
  #   cabinet.delete_if do |key, value|
  #     value[:age] < 18
  #   end
  #
  # @yieldparam [String] key the pair key
  # @yieldparam [Object] value the pair value
  def delete_if
    transaction do |db|
      db.delete_if do |key, value|
        yield key, value.from_yaml
      end
    end
  end

  # Iterates over each key-value pair in the database.
  #
  # @yieldparam [String] key the pair key
  # @yieldparam [Object] value the pair value
  def each
    transaction do |db|
      db.each do |key, value|
        yield key, value.from_yaml
      end
    end
  end

  # Iterates over each key in the database.
  #
  # @yieldparam [String] key the pair key
  def each_key(&block)
    transaction { |db| db.each_key(&block) }
  end

  # Iterates over each key-value pair in the database.
  #
  # @yieldparam [Object] value the pair value
  def each_value
    transaction do |db|
      db.each_value do |value|
        yield value.from_yaml
      end
    end
  end

  # @return [Boolean] +true+ if the database is empty.
  def empty?
    transaction(&:empty?)
  end

  # @return [Boolean] +true+ if the database contains the given key.
  def has_key?(key)
    transaction { |db| db.has_key? key.to_s }
  end
  alias include? has_key?
  alias key? has_key?

  # @return [Boolean] +true+ if the database contains the given value.
  def has_value?(value)
    transaction { |db| db.has_value? value.to_yaml }
  end
  alias value? has_value?

  # Returns the key associated with the given value.
  #
  # If more than one key corresponds to the given value, then the first key will be returned.
  # If no keys are found, +nil+ will be returned.
  #
  # @return [String] the key associated with the given value.
  def key(value)
    transaction { |db| db.key value.to_yaml }
  end

  # @return [Array] a new Array containing the keys in the database.
  def keys
    transaction(&:keys)
  end

  # @return [Integer] the number of keys in the database.
  def length
    transaction(&:length)
  end
  alias size length
  alias count length

  # Empties the database, then inserts the given key-value pairs.
  #
  # This method will work with any object which implements an +#each_pair+
  # method, such as a Hash, or with any object that implements an +#each+
  # method, such as an Array. In this case, the array will be converted to
  # a `key=key` hash before storing it.
  #
  # @example
  #   cabinet = HashCabinet.new 'filename'
  #   cabinet.replace key1: 'value1', key2: 'value2'
  #
  # @param [Object] data the data to store
  def replace(data)
    if !data.respond_to?(:each_pair) && data.respond_to?(:each)
      data = array_to_hash data
    end

    data = normalize_types data
    transaction { |db| db.replace data }
  end

  # @return [Hash] a new Hash of key-value pairs for which the block returns true.
  def select
    transaction do |db|
      db.select do |key, value|
        yield key, value.from_yaml
      end.to_h.transform_values(&:from_yaml)
    end
  end

  # Removes a key-value pair from the database and returns them as an Array.
  #
  # If the database is empty, returns nil.
  #
  # @return [Array] the key and value.
  def shift
    transaction do |db|
      result = db.shift
      [result[0], result[1].from_yaml]
    end
  end

  # @return [Array] a new array containing each key-value pair in the
  #   database.
  def to_a
    transaction do |db|
      db.to_a.map { |pair| [pair[0], pair[1].from_yaml] }
    end
  end

  # @return [hash] a new hash containing each key-value pair in the database.
  def to_h
    transaction do |db|
      db.to_h.transform_values(&:from_yaml)
    end
  end

  # Inserts or updates key-value pairs.
  #
  # This method will work with any object which implements an +#each_pair+
  # method, such as a Hash, or with any object that implements an +#each+
  # method, such as an Array. In this case, the array will be converted to
  # a `key=key` hash before storing it.
  #
  # @example
  #   cabinet = HashCabinet.new 'filename'
  #   cabinet.update key1: 'value1', key2: 'value2'
  #
  # @param [Object] data the data to store
  def update(data)
    if !data.respond_to?(:each_pair) && data.respond_to?(:each)
      data = array_to_hash data
    end

    data = normalize_types data
    transaction { |db| db.update data }
  end

  # @return [Array] a new array containing the values in the database.
  def values
    transaction do |db|
      db.values.map(&:from_yaml)
    end
  end

  # @return [Array] an Array of values corresponding to the given keys.
  def values_at(*key)
    transaction do |db|
      db.values_at(*key.map(&:to_s)).map(&:from_yaml)
    end
  end

private

  def array_to_hash(array)
    array.to_h { |item| [item, item] }
  end

  def normalize_types(hash)
    hash.to_h do |key, value|
      [key.to_s, value.to_yaml]
    end
  end
end

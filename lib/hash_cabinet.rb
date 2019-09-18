require 'sdbm'
require 'yaml'

class HashCabinet

  # Refinements to allow using +from_yaml+ as the opposite of +to_yaml+.
  module ReverseYAML
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

  using ReverseYAML

  # Returns the path to the database file.
  attr_reader :path

  # Initialize a new database file at {path}.
  def initialize(path)
    @path = path
  end

  # Yields the +SDBM+ object to the block. Under most circumstances, this
  # method should not be used directly, as it is used by all other methods.
  #
  # Example:
  #
  #   cabinet = HashCabinet.new 'filename'
  #
  #   cabinet.transaction do |db|
  #     db.clear
  #   end
  #
  def transaction(&block)
    SDBM.open path, &block
  end

  # Returns the value in the database associated with the given +key+.
  def [](key)
    transaction { |db| db[key].from_yaml }
  end

  # Inserts or updates a value in the database with the given key as an index.
  def []=(key, value)
    transaction { |db| db[key] = value.to_yaml }
  end

  # Deletes all key-value pairs from the database.
  def clear
    transaction { |db| db.clear }
  end

  # Deletes the given `key` from the database.
  def delete(key)
    transaction { |db| db.delete key }
  end

  # Iterates over the key-value pairs in the database, deleting those for
  # which the block returns true.
  def delete_if(&block)
    transaction do |db|
      db.delete_if do |key, value|
        yield key, value.from_yaml
      end
    end
  end

  # Iterates over each key-value pair in the database.
  def each(&block)
    transaction do |db|
      db.each do |key, value|
        yield key, value.from_yaml
      end
    end
  end

  
  # Iterates over each key in the database.
  def each_key(&block)
    transaction { |db| db.each_key &block }
  end

  
  # Iterates over each key-value pair in the database.
  def each_value(&block)
    transaction do |db|
      db.each_value do |value|
        yield value.from_yaml
      end
    end
  end

  # Returns +true+ if the database is empty.
  def empty?
    transaction { |db| db.empty? }
  end

  # Returns true if the database contains the given key.
  def has_key?(key)
    transaction { |db| db.has_key? key }
  end

  # Returns +true+ if the database contains the given value.
  def has_value?(value)
    transaction { |db| db.has_value? value.to_yaml }
  end

  # Returns +true+ if the database contains the given key.
  def include?(key)
    transaction { |db| db.include? key }
  end

  # Returns the key associated with the given value. If more than one key
  # corresponds to the given value, then the first key will be returned.
  # If no keys are found, +nil+ will be returned.
  def key(value)
    transaction { |db| db.key value.to_yaml }
  end

  # Returns +true+ if the database contains the given key.
  def key?(key)
    transaction { |db| db.key? key }
  end

  # Returns a new Array containing the keys in the database.
  def keys
    transaction { |db| db.keys }
  end

  # Returns the number of keys in the database.
  def length
    transaction { |db| db.length }
  end

  # Empties the database, then inserts the given key-value pairs.
  # This method will work with any object which implements an +#each_pair+
  # method, such as a Hash.
  def replace(data)
    data = data.transform_values &:to_yaml
    data = data.transform_keys &:to_s
    transaction { |db| db.replace data }
  end

  # Returns a new Hash of key-value pairs for which the block returns true.
  def select(&block)
    transaction do |db|
      db.select do |key, value|
        yield key, value.from_yaml
      end.to_h.transform_values &:from_yaml
    end
  end

  # Removes a key-value pair from the database and returns them as an Array.
  #
  # If the database is empty, returns nil.
  def shift
    transaction do |db| 
      result = db.shift
      [result[0], result[1].from_yaml]
    end
  end

  # Returns the number of keys in the database.
  def size
    transaction { |db| db.size }
  end

  # Returns a new Array containing each key-value pair in the database.
  def to_a
    transaction do |db| 
      db.to_a.map { |pair| [pair[0], pair[1].from_yaml] }
    end
  end

  # Returns a new Hash containing each key-value pair in the database.
  def to_h
    transaction do |db| 
      db.to_h.transform_values &:from_yaml
    end
  end

  # Insert or update key-value pairs.
  # 
  # This method will work with any object which implements an +#each_pair+
  # method, such as a Hash.
  def update(data)
    data = data.transform_values &:to_yaml
    transaction { |db| db.update data }
  end

  # Returns +true+ if the database contains the given value.
  def value?(value)
    transaction { |db| db.value? value.to_yaml }
  end

  # Returns a new Array containing the values in the database.
  def values
    transaction do |db| 
      db.values.map &:from_yaml
    end
  end

  # Returns an Array of values corresponding to the given keys.
  def values_at(*key)
    transaction do |db| 
      db.values_at(*key).map &:from_yaml
    end
  end

end

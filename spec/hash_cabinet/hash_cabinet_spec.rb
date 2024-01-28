require 'spec_helper'

describe HashCabinet do
  subject { described_class.new 'tmp/specdb' }

  before { create_dummy_db }

  let(:sample_value) { { name: 'Metallica', active_since: 1981, active_to: 'Present' } }
  let(:new_value) { { name: 'AC/DC', active_since: 1973 } }

  describe '#transaction' do
    it 'yields an SDBM instance' do
      subject.transaction do |db|
        expect(db).to be_an SDBM
      end
    end
  end

  describe '#[]' do
    it 'returns the value at key' do
      expect(subject['metallica']).to eq sample_value
    end

    context 'with a non-string key' do
      it 'converts the key to a string and returns the value' do
        expect(subject[:metallica]).to eq sample_value
      end
    end
  end

  describe '#[]=' do
    it 'saves the value at key' do
      expect(subject['acdc']).to be_nil
      subject['acdc'] = new_value
      expect(subject['acdc']).to eq new_value
    end

    context 'with a non-string key' do
      it 'converts the key to a string and saves the value' do
        expect(subject['acdc']).to be_nil
        subject[:acdc] = new_value
        expect(subject['acdc']).to eq new_value
      end
    end
  end

  describe '#clear' do
    it 'deletes all records' do
      expect(subject.size).to eq 3
      subject.clear
      expect(subject.size).to eq 0
    end
  end

  describe '#count' do
    it 'is the same as #length?' do
      expect(subject.method :count).to eq(subject.method :length)
    end
  end

  describe '#delete' do
    it 'deletes a key' do
      expect(subject['pantera']).to be_a Hash
      subject.delete 'pantera'
      expect(subject['pantera']).to be_nil
    end

    context 'with a non-string key' do
      it 'converts the key to a string and deletes' do
        expect(subject['pantera']).to be_a Hash
        subject.delete :pantera
        expect(subject['pantera']).to be_nil
      end
    end
  end

  describe '#delete_if' do
    it 'deletes a record if the yielded block evaluates to true' do
      expect(subject['pantera']).to be_a Hash
      subject.delete_if do |_key, value|
        value[:name] == 'Pantera'
      end
      expect(subject['pantera']).to be_nil
    end
  end

  describe '#each' do
    it 'yields each record to the block' do
      result = []
      subject.each_value do |value|
        result << value[:name]
      end
      expect(result).to eq ['Metallica', 'Iron Maiden', 'Pantera']
    end
  end

  describe '#each_key' do
    it 'yields each key to the block' do
      result = []
      subject.each_key do |key|
        result << key
      end
      expect(result).to eq %w[metallica iron-maiden pantera]
    end
  end

  describe '#each_value' do
    it 'yields each value to the block' do
      result = []
      subject.each_value do |value|
        result << value[:name]
      end
      expect(result).to eq ['Metallica', 'Iron Maiden', 'Pantera']
    end
  end

  describe '#empty?' do
    context 'when the database is not empty' do
      it 'returns false' do
        expect(subject.empty?).to be false
      end
    end

    context 'when the database is empty' do
      before { subject.clear }

      it 'returns true' do
        expect(subject.empty?).to be true
      end
    end
  end

  describe '#has_key?' do
    context 'when the key exists' do
      it 'returns true' do
        expect(subject.has_key? 'pantera').to be true
      end

      context 'with a non-string key' do
        it 'returns true' do
          expect(subject.has_key? :pantera).to be true
        end
      end
    end

    context 'when the key does not exist' do
      it 'returns false' do
        expect(subject.has_key? 'sepultura').to be false
      end
    end
  end

  describe '#has_value?' do
    context 'when the value exists' do
      it 'returns true' do
        expect(subject.has_value? sample_value).to be true
      end
    end

    context 'when the value does not exist' do
      it 'returns false' do
        expect(subject.has_value? new_value).to be false
      end
    end
  end

  describe '#include?' do
    it 'is the same as #has_key?' do
      expect(subject.method :include?).to eq(subject.method :has_key?)
    end
  end

  describe '#key' do
    context 'when the provided value is found' do
      it 'returns the key of a value' do
        expect(subject.key sample_value).to eq 'metallica'
      end
    end

    context 'when the provided value is not found' do
      it 'returns nil' do
        expect(subject.key new_value).to be_nil
      end
    end
  end

  describe '#key?' do
    it 'is the same as #has_key?' do
      expect(subject.method :key?).to eq(subject.method :has_key?)
    end
  end

  describe '#keys' do
    it 'returns an array of keys' do
      expect(subject.keys).to eq %w[metallica iron-maiden pantera]
    end
  end

  describe '#length' do
    it 'returns the database size' do
      expect(subject.length).to eq 3
    end
  end

  describe '#replace' do
    it 'clears the database and replaces new values in it' do
      expect(subject.size).to eq 3
      subject.replace acdc: new_value
      expect(subject.size).to eq 1
      expect(subject['acdc'][:name]).to eq 'AC/DC'
    end

    context 'with an array instead of a hash' do
      it 'stores data as key=key pairs while maintaining value types' do
        expect(subject.size).to eq 3
        subject.replace [123, '456']
        expect(subject.size).to eq 2
        expect(subject[123]).to eq 123
        expect(subject[456]).to eq '456'
      end
    end
  end

  describe '#select' do
    it 'returns a hash with records matching the block condition' do
      result = subject.select do |_key, value|
        value[:active_to] == 'Present'
      end

      expect(result.count).to eq 2
      expect(result['metallica'][:name]).to eq 'Metallica'
    end
  end

  describe '#shift' do
    it 'removes and returns a record' do
      expected = ['metallica', subject['metallica']]

      expect(subject.size).to eq 3
      expect(subject.shift).to eq expected
      expect(subject.size).to eq 2
    end
  end

  describe '#size' do
    it 'is the same as #length?' do
      expect(subject.method :size).to eq(subject.method :length)
    end
  end

  describe '#to_a' do
    it 'returns the entire database as an array with keys and values' do
      expect(subject.to_a.size).to eq 3
      expect(subject.to_a.first.last).to eq subject['metallica']
    end
  end

  describe '#to_h' do
    it 'returns the entire database as a hash' do
      expect(subject.to_h).to be_a Hash
      expect(subject.to_h.size).to eq 3
      expect(subject.to_h.keys).to eq subject.keys
    end
  end

  describe '#update' do
    it 'inserts or updates records in bulk' do
      metallica = subject['metallica']
      metallica[:active_to] = 'Forever'

      new_data = {
        'acdc'      => new_value,
        'metallica' => metallica,
      }

      subject.update new_data

      expect(subject.size).to eq 4
      expect(subject['metallica'][:active_to]).to eq 'Forever'
      expect(subject['acdc']).to eq new_value
    end

    context 'with an array instead of a hash' do
      it 'stores data as key=key pairs while maintaining value types' do
        subject.update [123, '456']

        expect(subject.size).to eq 5
        expect(subject[123]).to eq 123
        expect(subject[456]).to eq '456'
      end
    end
  end

  describe '#value?' do
    context 'when the provided value is in the database' do
      it 'returns true' do
        expect(subject.has_value? sample_value).to be true
      end
    end

    context 'when the provided value is not in the database' do
      it 'returns false' do
        expect(subject.has_value? new_value).to be false
      end
    end
  end

  describe 'values' do
    it 'returns an array of all values' do
      expect(subject.values).to be_an Array
      expect(subject.values.count).to eq 3
      expect(subject.values.first).to eq subject['metallica']
    end
  end

  describe '#values_at' do
    it 'returns an array of values corresponding to the given keys' do
      result = subject.values_at 'metallica', 'pantera'
      expect(result).to be_an Array
      expect(result.first).to eq subject['metallica']
      expect(result.last).to eq subject['pantera']
    end

    context 'with non-string keys' do
      it 'converts the keys to strings and returns the values' do
        result = subject.values_at :metallica, :pantera
        expect(result).to be_an Array
        expect(result.first).to eq subject['metallica']
        expect(result.last).to eq subject['pantera']
      end
    end
  end
end

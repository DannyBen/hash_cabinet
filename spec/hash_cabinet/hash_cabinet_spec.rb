require 'spec_helper'

describe HashCabinet do
  before { create_dummy_db }

  let(:sample_value) {{ name: "Metallica", active_since: 1981, active_to: 'Present' }}
  let(:new_value) {{ name: "AC/DC", active_since: 1973 }}

  subject { described_class.new 'tmp/specdb' }

  describe '#transaction' do
    it "yields an SDBM instance" do
      subject.transaction do |db|
        expect(db).to be_an SDBM
      end
    end
  end

  describe '#[] and #[]=' do
    it "saves a key/value pair" do
      expect(subject['acdc']).to be_nil
      subject['acdc'] = new_value
      expect(subject['acdc']).to eq new_value
    end
  end

  describe '#clear' do
    it "deletes all records" do
      expect(subject.size).to eq 3
      subject.clear
      expect(subject.size).to eq 0
    end
  end

  describe '#delete' do
    it "deletes a key" do
      expect(subject['pantera']).to be_a Hash
      subject.delete 'pantera'
      expect(subject['pantera']).to be_nil
    end
  end
  
  describe '#delete_if' do
    it "deletes a record if the yielded block evaluates to true" do
      expect(subject['pantera']).to be_a Hash
      subject.delete_if do |key, value|
        value[:name] == 'Pantera'
      end
      expect(subject['pantera']).to be_nil
    end
  end

  describe '#each' do
    it "yields each record to the block" do
      result = []
      subject.each do |key, value|
        result << value[:name]
      end
      expect(result).to eq ["Metallica", "Iron Maiden", "Pantera"]
    end
  end

  describe '#each_key' do
    it "yields each key to the block" do
      result = []
      subject.each_key do |key|
        result << key
      end
      expect(result).to eq ["metallica", "iron-maiden", "pantera"]
    end
  end

  describe '#each_value' do
    it "yields each value to the block" do
      result = []
      subject.each_value do |value|
        result << value[:name]
      end
      expect(result).to eq ["Metallica", "Iron Maiden", "Pantera"]
    end
  end

  describe '#empty?' do
    context "when the database is not empty" do
      it "returns false" do
        expect(subject.empty?).to be false
      end
    end

    context "when the database is empty" do
      before { subject.clear }

      it "returns true" do
        expect(subject.empty?).to be true        
      end
    end
  end

  describe '#has_key?' do
    context "when the key exists" do
      it "returns true" do
        expect(subject.has_key? 'pantera').to be true
      end
    end

    context "when the key does not exist" do
      it "returns false" do
        expect(subject.has_key? 'sepultura').to be false
      end
    end
  end

  describe '#has_value?' do
    context "when the value exists" do
      it "returns true" do
        expect(subject.has_value? sample_value).to be true
      end
    end

    context "when the value does not exist" do
      it "returns false" do
        expect(subject.has_value? new_value ).to be false
      end
    end
  end

  describe '#include?' do
    context "when the key exists" do
      it "returns true" do
        expect(subject.include? 'pantera').to be true
      end
    end

    context "when the key does not exist" do
      it "returns false" do
        expect(subject.include? 'sepultura').to be false
      end
    end
  end

  describe '#key' do
    context "when the provided value is found" do
      it "returns the key of a value" do
        expect(subject.key sample_value).to eq 'metallica'
      end
    end

    context "when the provided value is not found" do
      it "returns nil" do
        expect(subject.key new_value).to be_nil
      end
    end
  end

  describe '#key?' do
    context "when the key exists" do
      it "returns true" do
        expect(subject.key? 'pantera').to be true
      end
    end

    context "when the key does not exist" do
      it "returns false" do
        expect(subject.key? 'sepultura').to be false
      end
    end
  end

  describe '#keys' do
    it "returns an array of keys" do
      expect(subject.keys).to eq ["metallica", "iron-maiden", "pantera"]
    end
  end

  describe '#length' do
    it "returns the database size" do
      expect(subject.length).to eq 3
    end
  end

  describe '#replace' do
    it "clears the database and replaces new values in it" do
      expect(subject.size).to eq 3
      subject.replace acdc: new_value
      expect(subject.size).to eq 1
      expect(subject['acdc'][:name]).to eq "AC/DC"
    end
  end

  describe '#select' do
    it "returns a hash with records matching the block condition" do
      result = subject.select do |key, value|
        value[:active_to] == 'Present'
      end

      expect(result.count).to eq 2
      expect(result['metallica'][:name]).to eq "Metallica"
    end
  end

  describe '#shift' do
    it "removes and returns a record" do
      expected = ['metallica', subject['metallica'] ]

      expect(subject.size).to eq 3
      expect(subject.shift).to eq expected
      expect(subject.size).to eq 2
    end
  end

  describe '#size' do
    it "returns the database size" do
      expect(subject.size).to eq 3
    end
  end

  describe '#to_a' do
    it "returns the entire database as an array with keys and values" do
      expect(subject.to_a.size).to eq 3
      expect(subject.to_a.first.last).to eq subject['metallica']
    end
  end

  describe '#to_h' do
    it "returns the entire database as a hash" do
      expect(subject.to_h).to be_a Hash
      expect(subject.to_h.size).to eq 3
      expect(subject.to_h.keys).to eq subject.keys
    end
  end

  describe '#update' do
    it "inserts or updates records in bulk" do
      metallica = subject['metallica']
      metallica[:active_to] = 'Forever'

      new_data = {
        'acdc' => new_value,
        'metallica' => metallica
      }

      subject.update new_data

      expect(subject.size).to eq 4
      expect(subject['metallica'][:active_to]).to eq 'Forever'
      expect(subject['acdc']).to eq new_value
    end
  end

  describe '#value?' do
    context "when the provided value is in the database" do
      it "returns true" do
        expect(subject.value? sample_value).to be true
      end
    end

    context "when the provided value is not in the database" do
      it "returns false" do
        expect(subject.value? new_value).to be false
      end
    end
  end

  describe 'values' do
    it "returns an array of all values" do
      expect(subject.values).to be_an Array
      expect(subject.values.count).to eq 3
      expect(subject.values.first).to eq subject['metallica']
    end
  end

  describe '#values_at' do
    it "returns an array of values corresponding to the given keys" do
      result = subject.values_at 'metallica', 'pantera'
      expect(result).to be_an Array
      expect(result.first).to eq subject['metallica']
      expect(result.last).to eq subject['pantera']
    end
  end


end

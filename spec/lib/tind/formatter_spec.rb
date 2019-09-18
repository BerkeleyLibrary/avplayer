require 'rails_helper'
require 'tind'
require 'json'
require 'marc'

module TIND
  describe Formatter do
    attr_reader :formatter

    before(:all) do
      json_document = File.read('spec/data/tind_html_metadata_da.json')
      json = JSON.parse(json_document)
      @formatter = Formatter.from_json(json)
    end

    describe :from_json do

      it 'reads JSON' do
        expect(formatter).to be_a(Formatter)
      end

      it 'parses the fields' do
        formatter.fields.each_with_index { |f, i| puts "#{i}\t#{f}" }
      end

      it 'filters out duplicate fields' do
        all_542u = formatter.fields.find_all { |f| f.tag == "542" && f.subfield == "u" }
        expect(all_542u.size).to eq(1)
      end
    end

    describe :to_h do
      attr_reader :marc_record

      before(:all) do
        @marc_record = MARC::XMLReader.new('spec/data/record-21178.xml').first
      end

      it 'finds the fields' do
        h = formatter.to_hash(marc_record)
        pp h
      end
    end
  end
end

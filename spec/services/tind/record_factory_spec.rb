require 'rails_helper'
require 'marc'
require 'json'
require 'tind'

module Tind
  describe RecordFactory do
    attr_reader :factory

    before(:all) do
      json_document = File.read('spec/data/tind_html_metadata_da.json')
      json = JSON.parse(json_document)
      @factory = RecordFactory.from_json(json)
    end

    describe :from_json do

      it 'reads JSON' do
        expect(factory).to be_a(RecordFactory)
      end

      it 'parses the fields' do
        factory.field_factories.each_with_index { |f, i| puts "#{i}\t#{f}" }
      end

      it 'filters out duplicate fields' do
        all_542u = factory.field_factories.find_all { |f| f.tag == '542' && f.subfield == 'u' }
        expect(all_542u.size).to eq(1)
      end
    end

    describe :create_record_from_xml do
      attr_reader :tind_record

      before(:all) do
        marc_xml = File.read('spec/data/record-21178.xml')
        @tind_record = factory.create_record_from_xml(marc_xml)
      end

      it 'creates a record' do
        expect(tind_record).not_to be_nil
        expect(tind_record.title).to eq('Wanda Coleman')
      end
    end
  end
end

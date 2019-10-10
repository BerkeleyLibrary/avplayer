require 'rails_helper'

require 'tind'

module Tind
  describe ::Tind do

    attr_reader :ml_coleman, :ml_walker, :marc_to_tind

    before(:each) do
      @ml_walker = MarcLookup.new(field: '901o', value: '947286769')
      @ml_coleman = MarcLookup.new(field: '901m', value: 'b23305522')

      @marc_to_tind = {
        ml_walker => '19816',
        ml_coleman => '21178'
      }
      marc_to_tind.each do |ml, tind_001|
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{ml.value}&of=xm"
        marc_xml = File.read("spec/data/record-#{tind_001}.xml")
        stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
      end
    end

    describe :find_marc_record do
      it 'finds a MARC record by Millennium bib number' do
        marc_record = Tind.find_marc_record(ml_coleman)
        expect(marc_record).not_to be_nil
        expect(marc_record).to be_a(MARC::Record)

        expected_001 = marc_to_tind[ml_coleman]
        fields_001 = marc_record.fields('001')
        expect(fields_001.size).to eq(1)
        expect(fields_001[0].value).to eq(expected_001)
      end

      it 'finds a MARC record by OCLC record number' do
        marc_record = Tind.find_marc_record(ml_walker)
        expect(marc_record).not_to be_nil
        expect(marc_record).to be_a(MARC::Record)

        expected_001 = marc_to_tind[ml_walker]
        fields_001 = marc_record.fields('001')
        expect(fields_001.size).to eq(1)
        expect(fields_001[0].value).to eq(expected_001)
      end
    end
  end
end

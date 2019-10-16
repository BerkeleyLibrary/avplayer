require 'rails_helper'

require 'tind'

module Tind
  describe ::Tind do
    describe :find_marc_record do
      it 'finds a MARC record' do
        tind_id = 19_816
        search_url = Tind.marc_url_for(19_816)
        marc_xml = File.read('spec/data/record-19816.xml')
        stub_request(:get, search_url).to_return(status: 200, body: marc_xml)

        marc_record = Tind.find_marc_record(tind_id)
        expect(marc_record).not_to be_nil
        expect(marc_record).to be_a(MARC::Record)

        fields_001 = marc_record.fields('001')
        expect(fields_001.size).to eq(1)
        expect(fields_001[0].value).to eq('19816')
      end
    end
  end
end

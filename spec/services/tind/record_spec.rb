require 'rails_helper'

module Tind
  describe Record do
    describe :find do
      attr_reader :ml_coleman, :ml_walker, :expected_titles

      before(:each) do
        @ml_walker = MarcLookup.new(field: '901o', value: '947286769')
        @ml_coleman = MarcLookup.new(field: '901m', value: 'b23305522')

        @expected_titles = {
          ml_walker => 'Author Alice Walker reads the short story, Roselily',
          ml_coleman => 'Wanda Coleman'
        }

        marc_to_tind = {
          ml_walker => '19816',
          ml_coleman => '21178'
        }
        marc_to_tind.each do |ml, tind_001|
          search_url = "https://digicoll.lib.berkeley.edu/search?p=#{ml.value}&of=xm"
          marc_xml = File.read("spec/data/record-#{tind_001}.xml")
          stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
        end
      end

      it 'finds a record' do
        record = Record.find(ml_coleman)
        expected_title = expected_titles[ml_coleman]
        expect(record.title). to eq(expected_title)

        record = Record.find(ml_walker)
        expected_title = expected_titles[ml_walker]
        expect(record.title). to eq(expected_title)
      end
    end

    describe :find_millennium do
      it 'finds a record' do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        marc_html = File.read('spec/data/b22139658.html')
        stub_request(:get, search_url).to_return(status: 200, body: marc_html)

        record = Record.find_millennium('b22139658')
        expect(record.title).to eq('Communists on campus')
      end
    end
  end
end

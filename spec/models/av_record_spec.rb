require 'rails_helper'

describe AvRecord do
  attr_reader :ml_coleman, :ml_walker, :ml_spellingbee, :marc_to_tind

  before(:each) do
    @ml_walker = Tind::MarcLookup.new(field: '901o', value: '947286769')
    @ml_coleman = Tind::MarcLookup.new(field: '901m', value: 'b23305522')
    @ml_spellingbee = Tind::MarcLookup.new(field: '901m', value: 'b18538031')

    @marc_to_tind = {
      ml_walker => '19816',
      ml_coleman => '21178',
      ml_spellingbee => '4188'
    }
    marc_to_tind.each do |ml, tind_001|
      search_url = "https://digicoll.lib.berkeley.edu/search?p=#{ml.value}&of=xm"
      marc_xml = File.read("spec/data/record-#{tind_001}.xml")
      stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
    end
  end

  it 'extracts the restrictions from the 856 field' do
    expected_restrictions = {
      # ml_walker => Tind::Restrictions::PUBLIC,
      # ml_coleman => Tind::Restrictions::PUBLIC,
      ml_spellingbee => Tind::Restrictions::UCB_IP
    }
    aggregate_failures 'restrictions' do
      expected_restrictions.each do |ml, expected|
        record = AvRecord.new(collection: nil, files: [], marc_lookups: [ml])
        expect(record.restrictions).to eq(expected)
      end
    end
  end
end

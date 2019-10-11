require 'rails_helper'

describe AvRecord do
  attr_reader :ml_coleman, :ml_walker, :ml_spellingbee, :marc_to_tind

  before(:each) do
    @ml_walker = Metadata::Key.new(source: Metadata::Source::TIND, bib_number: 'b23305516')
    @ml_coleman = Metadata::Key.new(source: Metadata::Source::TIND, bib_number: 'b23305522')
    @ml_spellingbee = Metadata::Key.new(source: Metadata::Source::TIND, bib_number: 'b18538031')

    @marc_to_tind = {
      ml_walker => '19816',
      ml_coleman => '21178',
      ml_spellingbee => '4188'
    }
    marc_to_tind.each do |mk, tind_001|
      search_url = "https://digicoll.lib.berkeley.edu/search?p=#{mk.bib_number}&of=xm"
      marc_xml = File.read("spec/data/record-#{tind_001}.xml")
      stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
    end
  end

  it 'extracts the restrictions from the 856 field' do
    expected_restrictions = {
      # ml_walker => Restrictions::PUBLIC,
      # ml_coleman => Restrictions::PUBLIC,
      ml_spellingbee => Restrictions::UCB_IP
    }
    aggregate_failures 'restrictions' do
      expected_restrictions.each do |mk, expected|
        record = AvRecord.new(files: [], metadata_key: mk)
        expect(record.restrictions).to eq(expected)
      end
    end
  end
end

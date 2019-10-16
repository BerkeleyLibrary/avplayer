require 'rails_helper'

describe AvRecord do
  attr_reader :mk_coleman, :mk_walker, :mk_spellingbee, :keys

  before(:each) do
    @mk_walker = Metadata::Key.new(source: Metadata::Source::TIND, bib_number: 'b23305516', tind_id: 19_816)
    @mk_coleman = Metadata::Key.new(source: Metadata::Source::TIND, bib_number: 'b23305522', tind_id: 21_178)
    @mk_spellingbee = Metadata::Key.new(source: Metadata::Source::TIND, bib_number: 'b18538031', tind_id: 4188)

    @keys = [mk_walker, mk_coleman, mk_spellingbee]

    keys.map(&:tind_id).each do |tind_id|
      search_url = Tind.marc_url_for(tind_id)
      marc_xml = File.read("spec/data/record-#{tind_id}.xml")
      stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
    end
  end

  it 'extracts the restrictions from the 856 field' do
    expected_restrictions = {
      mk_walker => Restrictions::PUBLIC,
      mk_coleman => Restrictions::PUBLIC,
      mk_spellingbee => Restrictions::UCB_IP
    }
    aggregate_failures 'restrictions' do
      expected_restrictions.each do |mk, expected|
        record = AvRecord.new(files: [], metadata_key: mk)
        expect(record.restrictions).to eq(expected)
      end
    end
  end
end

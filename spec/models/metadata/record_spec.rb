require 'rails_helper'

module Metadata
  describe Record do
    attr_reader :mk_coleman, :mk_walker, :marc_to_tind

    before(:each) do
      @mk_walker = Key.new(source: Source::TIND, bib_number: '947286769')
      @mk_coleman = Key.new(source: Source::TIND, bib_number: 'b23305522')

      @marc_to_tind = {
        mk_walker => '19816',
        mk_coleman => '21178'
      }
      marc_to_tind.each do |mk, tind_001|
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{mk.bib_number}&of=xm"
        marc_xml = File.read("spec/data/record-#{tind_001}.xml")
        stub_request(:get, search_url).to_return(status: 200, body: marc_xml)
      end
    end

    describe :find do
      it 'finds records' do
        expected_titles = {
          mk_walker => 'Author Alice Walker reads the short story, Roselily',
          mk_coleman => 'Wanda Coleman'
        }

        marc_to_tind.keys.each do |metadata_key|
          rec = Record.find(metadata_key)
          expect(rec).not_to be_nil
          expect(rec).to be_a(Metadata::Record)

          expected_title = expected_titles[metadata_key]
          expect(rec.title).to eq(expected_title)
        end
      end

      it "raises #{ActiveRecord::RecordNotFound} if no record can be found" do
        mk_missing = Key.new(source: Source::TIND, bib_number: 'not a real record')
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{mk_missing.bib_number}&of=xm"
        empty_result = File.read('spec/data/record-empty-result.xml')
        stub_request(:get, search_url).to_return(status: 200, body: empty_result)

        expect { Record.find(mk_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if TIND returns a 404" do
        mk_missing = Key.new(source: Source::TIND, bib_number: 'not a real record')
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{mk_missing.bib_number}&of=xm"
        stub_request(:get, search_url).to_return(status: 404)

        expect { Record.find(mk_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if TIND returns a 500" do
        mk_missing = Key.new(source: Source::TIND, bib_number: 'not a real record')
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{mk_missing.bib_number}&of=xm"
        stub_request(:get, search_url).to_return(status: 500)

        expect { Record.find(mk_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if TIND returns something weird" do
        mk_missing = Key.new(source: Source::TIND, bib_number: 'not a real record')
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{mk_missing.bib_number}&of=xm"

        # In general, RestClient throws exceptions for 4xx, 5xx, etc.,
        # and follows redirects for 3xx. 206 Partial Content isn't a
        # legit TIND response, but let's just make sure we'd treat an
        # unexpected 'non-error' response as an error.
        stub_request(:get, search_url).to_return(status: 206)

        expect { Record.find(mk_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

require 'rails_helper'

module Metadata
  describe Record do
    attr_reader :mk_communists, :mk_walker, :marc_to_tind, :expected_titles

    before(:each) do
      @mk_walker = Key.new(source: Source::TIND, tind_id: 19_816)
      @mk_communists = Key.new(source: Source::MILLENNIUM, bib_number: 'b22139658')

      @expected_titles = {
        mk_walker => 'Author Alice Walker reads the short story, Roselily',
        mk_communists => 'Communists on campus'
      }

      walker_marc_xml = File.read('spec/data/record-19816.xml')
      stub_request(:get, Tind.marc_url_for(mk_walker.tind_id)).to_return(status: 200, body: walker_marc_xml)

      communists_marc_html = File.read('spec/data/b22139658.html')
      stub_request(:get, Millennium.marc_url_for(mk_communists.bib_number)).to_return(status: 200, body: communists_marc_html)
    end

    describe :find do
      it 'finds records' do
        expected_titles.keys.each do |metadata_key|
          rec = Record.find(metadata_key)
          expect(rec).not_to be_nil
          expect(rec).to be_a(Metadata::Record)

          expected_title = expected_titles[metadata_key]
          expect(rec.title).to eq(expected_title)
        end
      end

      it "raises #{ArgumentError} for a bogus metadata source" do
        source = instance_double(Source)
        key = Key.new(source: source, bib_number: '12345')
        expect { Record.find(key) }.to raise_error(ArgumentError)
      end

      it "raises #{ActiveRecord::RecordNotFound} if no record can be found" do
        mk_missing = Key.new(source: Source::TIND, tind_id: 999)
        search_url = Tind.marc_url_for(999)
        empty_result = File.read('spec/data/record-empty-result.xml')
        stub_request(:get, search_url).to_return(status: 200, body: empty_result)

        expect { Record.find(mk_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if TIND returns a 404" do
        mk_missing = Key.new(source: Source::TIND, tind_id: 999)
        search_url = Tind.marc_url_for(999)
        stub_request(:get, search_url).to_return(status: 404)

        expect { Record.find(mk_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if TIND returns a 500" do
        mk_missing = Key.new(source: Source::TIND, tind_id: 999)
        search_url = Tind.marc_url_for(999)
        stub_request(:get, search_url).to_return(status: 500)

        expect { Record.find(mk_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if TIND returns something weird" do
        mk_missing = Key.new(source: Source::TIND, tind_id: 999)
        search_url = Tind.marc_url_for(999)

        # In general, RestClient throws exceptions for 4xx, 5xx, etc.,
        # and follows redirects for 3xx. 206 Partial Content isn't a
        # legit TIND response, but let's just make sure we'd treat an
        # unexpected 'non-error' response as an error.
        stub_request(:get, search_url).to_return(status: 206)

        expect { Record.find(mk_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if TIND redirects to a login page" do
        key = Key.new(source: Source::TIND, tind_id: 4959)
        search_url = Tind.marc_url_for(4959)
        stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/record-redirect-to-login.html'))

        expect { Record.find(key) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

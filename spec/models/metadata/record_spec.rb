require 'rails_helper'

module Metadata
  describe Record do
    attr_reader :ml_coleman, :ml_walker, :marc_to_tind

    before(:each) do
      @ml_walker = Key.new(field: '901o', value: '947286769')
      @ml_coleman = Key.new(field: '901m', value: 'b23305522')

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

    describe :find do
      it 'finds records' do
        expected_titles = {
          ml_walker => 'Author Alice Walker reads the short story, Roselily',
          ml_coleman => 'Wanda Coleman'
        }

        marc_to_tind.keys.each do |marc_lookup|
          rec = Record.find(marc_lookup)
          expect(rec).not_to be_nil
          expect(rec).to be_a(Metadata::Record)

          expected_title = expected_titles[marc_lookup]
          expect(rec.title).to eq(expected_title)
        end
      end

      it "raises #{ActiveRecord::RecordNotFound} if no record can be found" do
        ml_missing = Key.new(field: '901m', value: 'not a real record')
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{ml_missing.value}&of=xm"
        empty_result = File.read('spec/data/record-empty-result.xml')
        stub_request(:get, search_url).to_return(status: 200, body: empty_result)

        expect { Record.find(ml_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if TIND returns a 404" do
        ml_missing = Key.new(field: '901m', value: 'not a real record')
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{ml_missing.value}&of=xm"
        stub_request(:get, search_url).to_return(status: 404)

        expect { Record.find(ml_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if TIND returns a 500" do
        ml_missing = Key.new(field: '901m', value: 'not a real record')
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{ml_missing.value}&of=xm"
        stub_request(:get, search_url).to_return(status: 500)

        expect { Record.find(ml_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if TIND returns something weird" do
        ml_missing = Key.new(field: '901m', value: 'not a real record')
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{ml_missing.value}&of=xm"

        # In general, RestClient throws exceptions for 4xx, 5xx, etc.,
        # and follows redirects for 3xx. 206 Partial Content isn't a
        # legit TIND response, but let's just make sure we'd treat an
        # unexpected 'non-error' response as an error.
        stub_request(:get, search_url).to_return(status: 206)

        expect { Record.find(ml_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if TIND returns a record that doesn't match the ID" do
        ml_missing = Key.new(field: '901m', value: 'not a real record')
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{ml_missing.value}&of=xm"
        some_other_marc_xml = File.read('spec/data/record-19816.xml')
        stub_request(:get, search_url).to_return(status: 200, body: some_other_marc_xml)

        expect { Record.find(ml_missing) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe :find_any do
      it 'finds a record' do
        record = Record.find_any(marc_to_tind.keys)
        expect(record).not_to be_nil
        expect(record).to be_a(Metadata::Record)
      end

      it 'finds a record even if some lookups are missing' do
        ml_missing = Key.new(field: '901m', value: 'not a real record')
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{ml_missing.value}&of=xm"
        empty_result = File.read('spec/data/record-empty-result.xml')
        stub_request(:get, search_url).to_return(status: 200, body: empty_result)

        record = Record.find_any([ml_missing] + marc_to_tind.keys)
        expect(record).not_to be_nil
        expect(record).to be_a(Metadata::Record)
      end

      it 'finds a record even if some lookups raise an error' do
        ml_missing = Key.new(field: '901m', value: 'not a real record')
        search_url = "https://digicoll.lib.berkeley.edu/search?p=#{ml_missing.value}&of=xm"
        stub_request(:get, search_url).to_return(status: 500)

        record = Record.find_any([ml_missing] + marc_to_tind.keys)
        expect(record).not_to be_nil
        expect(record).to be_a(Metadata::Record)
      end

      it "raises #{ActiveRecord::RecordNotFound} if no records can be found" do
        empty_result = File.read('spec/data/record-empty-result.xml')
        mls_missing = [
          Key.new(field: '901m', value: 'not a real record'),
          Key.new(field: '901o', value: 'also not a real record')
        ]
        mls_missing.each do |ml|
          search_url = "https://digicoll.lib.berkeley.edu/search?p=#{ml.value}&of=xm"
          stub_request(:get, search_url).to_return(status: 200, body: empty_result)
        end

        expect { Record.find_any(mls_missing) }.to raise_error(ActiveRecord::RecordNotFound)
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
end

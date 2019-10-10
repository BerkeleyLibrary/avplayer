require 'rails_helper'
require 'active_record'

module Millennium
  describe ::Millennium do
    describe :find_marc_record do
      it 'finds a MARC record' do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        marc_html = File.read('spec/data/b22139658.html')
        stub_request(:get, search_url).to_return(status: 200, body: marc_html)

        marc_record = Millennium.find_marc_record('b22139658')
        title = marc_record['245']
        expect(title['a']).to eq('Communists on campus')
        expect(title['h']).to eq('[electronic resource] /')
        expect(title['c']).to eq('presented by the National Education Program, Searcy, Arkansas ; writer and producer, Sidney O. Fields.')

        expected_summary = <<~TEXT
          An American propaganda documentary created "to inform and
          impress on American citizens the true nature and the true
          magnitude of those forces that are working within our
          nation for its overthrow...and the destruction of our
          educational system." Film covers the July 1969 California
          Revolutionary Conference and other demonstrations, warning
          against the activities of Students for a Democratic
          Society, the Black Panthers, student protestors and
          Vietnam War demonstrators as they promote a "socialist/
          communist overthrow of the U.S. government," taking as
          their mentor Chairman Mao Tse-Tung.
        TEXT
        expected_summary = expected_summary.gsub("\n", ' ').strip

        summary = marc_record['520']
        expect(summary['a']).to eq(expected_summary)

        personal_names = marc_record.fields('700')
        expect(personal_names.size).to eq(27)
      end

      it "raises #{ActiveRecord::RecordNotFound} if the record cannot be found" do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        stub_request(:get, search_url).to_return(status: 404, body: '')

        expect { Millennium.find_marc_record('b22139658') }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if the record cannot be parsed" do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        stub_request(:get, search_url).to_return(status: 200, body: 'Something that is not a Millennium MARC HTML page')

        expect { Millennium.find_marc_record('b22139658') }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises #{ActiveRecord::RecordNotFound} if Millennium returns a weird HTTP status" do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        marc_html = File.read('spec/data/b22139658.html')
        stub_request(:get, search_url).to_return(status: 207, body: marc_html)

        expect { Millennium.find_marc_record('b22139658') }.to raise_error(ActiveRecord::RecordNotFound)
      end

    end
  end
end

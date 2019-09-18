require 'rails_helper'
require 'tind'
require 'json'

module TIND::Display
  describe Config do
    describe :from_json do
      attr_reader :html_md

      before :all do
        json_document = File.read('spec/data/tind_html_metadata_da.json')
        json = JSON.parse(json_document)
        @html_md = Config.from_json(json)
      end

      it 'reads JSON' do
        expect(html_md).to be_a(Config)
      end
    end
  end
end

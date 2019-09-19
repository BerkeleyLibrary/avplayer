require 'rails_helper'
require 'marc'
require 'tind'

module TIND
  describe Field do
    attr_reader :marc_record

    before(:all) do
      @marc_record = MARC::XMLReader.new('spec/data/record-21178.xml').first
    end

    describe :default_fields do
      describe :CREATOR_PERSONAL do
        it 'extracts the values' do
          field = Parser::CREATOR_PERSONAL
          values = field.values_from(marc_record)
          expected = [
            {a: 'Coleman, Wanda.', e: 'interviewee.'},
            {a: 'Adisa, Opal Palmer.', e: 'interviewer.'}
          ]
          expect(values).to eq(expected)
        end
      end

      describe :CREATOR_CORPORATE do
        it 'extracts the values' do
          field = Parser::CREATOR_CORPORATE
          values = field.values_from(marc_record)
          expected = [{a: 'Pacifica Radio Archive.'}, {a: "KPFA (Radio station : Berkeley, Calif.)."}]
          expect(values).to eq(expected)
        end
      end

      describe :LINKS_HTTP do
        it 'extracts the values' do
          field = Parser::LINKS_HTTP
          values = field.values_from(marc_record)
          expected = [{u: 'http://oskicat.berkeley.edu/record=b23305522', y: "View library catalog record."}]
          expect(values).to eq(expected)
        end
      end
    end
  end
end

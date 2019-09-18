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
          field = Formatter::CREATOR_PERSONAL
          values = field.values_from(marc_record)
          expected = ['Coleman, Wanda. interviewee.', "Adisa, Opal Palmer. interviewer."]
          expect(values).to eq(expected)
        end
      end

      describe :CREATOR_CORPORATE do
        it 'extracts the values' do
          field = Formatter::CREATOR_CORPORATE
          values = field.values_from(marc_record)
          expected = ['Pacifica Radio Archive.', "KPFA (Radio station : Berkeley, Calif.)."]
          expect(values).to eq(expected)
        end
      end

      describe :LINKS_HTTP do
        # TODO: something smarter than subfields_separator (typed values?)
        it 'extracts the values' do
          field = Formatter::LINKS_HTTP
          values = field.values_from(marc_record)
          expected = ['http://oskicat.berkeley.edu/record=b23305522', "View library catalog record."]
          expect(values).to eq(expected)
        end
      end
    end
  end
end

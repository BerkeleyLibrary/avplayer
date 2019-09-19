require 'rails_helper'
require 'marc'
require 'tind'

module Tind
  describe FieldFactory do
    attr_reader :marc_record

    before(:all) do
      @marc_record = MARC::XMLReader.new('spec/data/record-21178.xml').first
    end

    describe :default_fields do
      describe :CREATOR_PERSONAL do
        it 'extracts the values' do
          factory = RecordFactory::CREATOR_PERSONAL
          field = factory.create_field(marc_record)
          expect(field).to be_a(Tind::TextField)
          expected = ['Coleman, Wanda. interviewee.', 'Adisa, Opal Palmer. interviewer.']
          expect(field.lines).to eq(expected)
        end
      end

      describe :CREATOR_CORPORATE do
        it 'extracts the values' do
          factory = RecordFactory::CREATOR_CORPORATE
          field = factory.create_field(marc_record)
          expect(field).to be_a(Tind::TextField)
          expected = ['Pacifica Radio Archive.', 'KPFA (Radio station : Berkeley, Calif.).']
          expect(field.lines).to eq(expected)
        end
      end

      describe :LINKS_HTTP do
        it 'extracts the values' do
          factory = RecordFactory::LINKS_HTTP
          field = factory.create_field(marc_record)
          expect(field).to be_a(Tind::LinkField)

          links = field.links
          expect(links.size).to eq(1)

          link = links[0]

          expect(link.url).to eq('http://oskicat.berkeley.edu/record=b23305522')
          expect(link.body).to eq('View library catalog record.')
        end
      end
    end
  end
end

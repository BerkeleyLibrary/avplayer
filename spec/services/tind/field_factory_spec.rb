require 'rails_helper'
require 'marc'
require 'tind'

module Tind
  describe FieldFactory do
    attr_reader :marc_record

    before(:all) do
      @marc_record = MARC::XMLReader.new('spec/data/record-21178.xml').first
    end

    describe :<=> do
      it 'treats fields that differ only in subfield order as different' do
        args1 = { order: 4, marc_tag: '711%%%', label: 'Meeting Name', subfields_separator: ', ', subfield_order: 'a,n,d,c' }
        args2 = args1.merge(subfield_order: 'c,n,d,a')
        ff1 = FieldFactory.new(args1)
        ff2 = FieldFactory.new(args2)
        expect(ff1 < ff2).to be_truthy
        expect(ff2 > ff1).to be_truthy
      end
    end

    describe :to_s do
      it 'includes all pertinent info' do
        ff = FieldFactory.new(order: 4, marc_tag: '711%%%', label: 'Meeting Name', subfields_separator: ', ', subfield_order: 'c,n,d,a')
        ffs = ff.to_s
        ['4', '711', 'Meeting Name'].each { |v| expect(ffs).to include(v) }
      end
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

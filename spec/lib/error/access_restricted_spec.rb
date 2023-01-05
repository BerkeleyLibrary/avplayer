require 'rails_helper'

module Error
  describe AccessRestricted do
    it 'accepts a raw string message' do
      msg = 'the message'

      expect { raise(AccessRestricted, msg) }.to raise_error(AccessRestricted) do |ex|
        expect(ex.message).to eq(msg)
      end
    end

    context 'accepts an AV::Record' do
      it 'returns a custom message for UCB-only records' do
        record_id = '991054360089706532'
        marc_record = MARC::XMLReader.new("spec/data/alma/#{record_id}-sru.xml").first
        metadata = BerkeleyLibrary::AV::Metadata.new(record_id:, source: BerkeleyLibrary::AV::Metadata::Source::ALMA, marc_record:)
        collection = 'test'
        record = BerkeleyLibrary::AV::Record.new(
          collection:,
          metadata:,
          tracks: BerkeleyLibrary::AV::Track.tracks_from(metadata.marc_record, collection:)
        )
        expect(record.calnet_or_ip?).to eq(true) # just to be sure
        expect(record.calnet_only?).to eq(false) # just to be sure

        expected_message = format(AccessRestricted::MSG_FMT_UCB_ACCESS, record_id)
        expect { raise(AccessRestricted, record) }.to raise_error(AccessRestricted, expected_message)
      end

      it 'returns a custom message for CalNet records' do
        record_id = '991047179369706532'
        marc_record = MARC::XMLReader.new("spec/data/alma/#{record_id}-sru.xml").first
        metadata = BerkeleyLibrary::AV::Metadata.new(record_id:, source: BerkeleyLibrary::AV::Metadata::Source::ALMA, marc_record:)
        collection = 'test'
        record = BerkeleyLibrary::AV::Record.new(
          collection:,
          metadata:,
          tracks: BerkeleyLibrary::AV::Track.tracks_from(metadata.marc_record, collection:)
        )
        expect(record.calnet_or_ip?).to eq(true) # just to be sure
        expect(record.calnet_only?).to eq(true) # just to be sure

        expected_message = format(AccessRestricted::MSG_FMT_CALNET_ONLY, record_id)
        expect { raise(AccessRestricted, record) }.to raise_error(AccessRestricted, expected_message)
      end

      it 'accepts a string argument and a cause' do
        msg_inner = 'oopsy'
        msg_outer = 'oops'

        begin
          begin
            raise ArgumentError, msg_outer
          rescue StandardError => e
            ex_inner = e
            raise AccessRestricted, msg_inner
          end
        rescue AccessRestricted => e
          ex_outer = e
        end

        expect(ex_outer).to be_a(AccessRestricted)
        expect(ex_outer.message).to eq(msg_inner)
        expect(ex_outer.cause).to eq(ex_inner)
      end

      it 'accepts a record argument and a cause' do
        record_id = '991047179369706532'
        marc_record = MARC::XMLReader.new("spec/data/alma/#{record_id}-sru.xml").first
        metadata = BerkeleyLibrary::AV::Metadata.new(record_id:, source: BerkeleyLibrary::AV::Metadata::Source::ALMA, marc_record:)
        collection = 'test'
        record = BerkeleyLibrary::AV::Record.new(
          collection:,
          metadata:,
          tracks: BerkeleyLibrary::AV::Track.tracks_from(metadata.marc_record, collection:)
        )

        arg_inner = record
        msg_outer = 'oops'

        begin
          begin
            raise ArgumentError, msg_outer
          rescue StandardError => e
            ex_inner = e
            raise AccessRestricted, arg_inner
          end
        rescue AccessRestricted => e
          ex_outer = e
        end

        expect(ex_outer).to be_a(AccessRestricted)
        expect(ex_outer.message).to include(arg_inner.record_id)
        expect(ex_outer.cause).to eq(ex_inner)
      end
    end
  end
end

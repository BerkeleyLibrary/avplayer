require 'rails_helper'

module Error
  describe RecordNotAvailable do
    it 'accepts a raw string message' do
      msg = 'the message'

      expect { raise(RecordNotAvailable, msg) }.to raise_error(RecordNotAvailable) do |ex|
        expect(ex.message).to eq(msg)
      end
    end

    context 'accepts an AV::Record' do
      it 'returns a custom message for UCB-only records' do
        record_id = '991054360089706532'
        marc_record = MARC::XMLReader.new("spec/data/alma/#{record_id}-sru.xml").first
        metadata = AV::Metadata.new(record_id: record_id, source: AV::Metadata::Source::ALMA, marc_record: marc_record)
        collection = 'test'
        record = AV::Record.new(
          collection: collection,
          metadata: metadata,
          tracks: AV::Track.tracks_from(metadata.marc_record, collection: collection)
        )
        expect(record.ucb_access?).to eq(true) # just to be sure
        expect(record.calnet_only?).to eq(false) # just to be sure

        expected_message = format(RecordNotAvailable::MSG_FMT_UCB_ACCESS, record_id)
        expect { raise(RecordNotAvailable, record) }.to raise_error(RecordNotAvailable, expected_message)
      end

      it 'returns a custom message for CalNet records' do
        record_id = '991047179369706532'
        marc_record = MARC::XMLReader.new("spec/data/alma/#{record_id}-sru.xml").first
        metadata = AV::Metadata.new(record_id: record_id, source: AV::Metadata::Source::ALMA, marc_record: marc_record)
        collection = 'test'
        record = AV::Record.new(
          collection: collection,
          metadata: metadata,
          tracks: AV::Track.tracks_from(metadata.marc_record, collection: collection)
        )
        expect(record.ucb_access?).to eq(true) # just to be sure
        expect(record.calnet_only?).to eq(true) # just to be sure

        expected_message = format(RecordNotAvailable::MSG_FMT_CALNET_ONLY, record_id)
        expect { raise(RecordNotAvailable, record) }.to raise_error(RecordNotAvailable, expected_message)
      end

      it 'accepts a string argument and a cause' do
        msg_inner = 'oopsy'
        msg_outer = 'oops'

        begin
          begin
            raise ArgumentError, msg_outer
          rescue StandardError => e
            ex_inner = e
            raise RecordNotAvailable, msg_inner
          end
        rescue RecordNotAvailable => e
          ex_outer = e
        end

        expect(ex_outer).to be_a(RecordNotAvailable)
        expect(ex_outer.message).to eq(msg_inner)
        expect(ex_outer.cause).to eq(ex_inner)
      end

      it 'accepts a record argument and a cause' do
        record_id = '991047179369706532'
        marc_record = MARC::XMLReader.new("spec/data/alma/#{record_id}-sru.xml").first
        metadata = AV::Metadata.new(record_id: record_id, source: AV::Metadata::Source::ALMA, marc_record: marc_record)
        collection = 'test'
        record = AV::Record.new(
          collection: collection,
          metadata: metadata,
          tracks: AV::Track.tracks_from(metadata.marc_record, collection: collection)
        )

        arg_inner = record
        msg_outer = 'oops'

        begin
          begin
            raise ArgumentError, msg_outer
          rescue StandardError => e
            ex_inner = e
            raise RecordNotAvailable, arg_inner
          end
        rescue RecordNotAvailable => e
          ex_outer = e
        end

        expect(ex_outer).to be_a(RecordNotAvailable)
        expect(ex_outer.message).to include(arg_inner.record_id)
        expect(ex_outer.cause).to eq(ex_inner)
      end
    end
  end
end

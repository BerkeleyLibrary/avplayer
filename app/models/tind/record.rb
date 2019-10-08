require 'active_record/errors'

module Tind
  class Record

    attr_reader :title
    attr_reader :fields

    # @param title [String]
    # @param fields [Array<Tind::Field>]
    def initialize(title:, fields:)
      @title = title
      @fields = fields
    end

    UNKNOWN_TITLE = 'Unknown title'.freeze
    RECORD_NOT_FOUND = 'Record not found'.freeze
    NONE = Record.new(title: RECORD_NOT_FOUND, fields: [].freeze)

    class << self
      def find(tind_id)
        marc_record = Tind.find_marc_record(tind_id)
        raise ActiveRecord::RecordNotFound, "No record found for TIND ID #{tind_id}" unless marc_record

        Tind.record_factory.create_record_from_marc(marc_record)
      end

      def find_any(tind_ids)
        tind_ids.each do |tind_id|
          marc_record = Tind.find_marc_record(tind_id)
          return Tind.record_factory.create_record_from_marc(marc_record) if marc_record
        end
        raise ActiveRecord::RecordNotFound, "No record found for any TIND ID in: #{tind_ids}"
      end
    end
  end
end

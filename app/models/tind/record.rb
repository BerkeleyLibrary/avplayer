require 'active_record/errors'

module Tind
  class Record

    attr_reader :title
    attr_reader :fields
    attr_reader :restrictions

    # @param title [String]
    # @param fields [Array<Tind::Field>]
    # @param restrictions [Restrictions]
    def initialize(title:, fields:, restrictions: Restrictions::PUBLIC)
      @title = title
      @fields = fields
      @restrictions = restrictions
    end

    UNKNOWN_TITLE = 'Unknown title'.freeze
    RECORD_NOT_FOUND = 'Record not found'.freeze
    NONE = Record.new(title: RECORD_NOT_FOUND, fields: [].freeze)

    class << self

      # Searches for a TIND record matching the specified MARC lookup key
      #
      # @param @marc_lookup [Tind::MarcLookup] The key to look up
      # @return [Tind::Record] The record
      # @raise [ActiveRecord::RecordNotFound] if the record could not be found
      def find(marc_lookup)
        marc_record = Tind.find_marc_record(marc_lookup)
        raise ActiveRecord::RecordNotFound, "No record found for TIND ID #{marc_lookup}" unless marc_record

        Tind.record_factory.create_record_from_marc(marc_record)
      end

      # Searches for a TIND record matching any one of several MARC lookup keys
      #
      # @param @marc_lookups [Array<Tind::MarcLookup>] The keys to look up
      # @return [Tind::Record] The first record found
      # @raise [ActiveRecord::RecordNotFound] if the record could not be found
      def find_any(marc_lookups)
        marc_lookups.each do |marc_lookup|
          marc_record = find_quietly(marc_lookup)
          return Tind.record_factory.create_record_from_marc(marc_record) if marc_record
        end
        raise ActiveRecord::RecordNotFound, "No record found for any TIND ID in: #{marc_lookups}"
      end

      private

      def log
        Rails.logger
      end

      def find_quietly(marc_lookup)
        Tind.find_marc_record(marc_lookup)
      rescue ActiveRecord::RecordNotFound => e
        log.trace("Ignoring #{e} in find_quietly(#{marc_lookup})")
        nil
      end
    end
  end
end

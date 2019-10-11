require 'active_record/errors'
require 'millennium'

module Metadata
  class Record

    attr_reader :title
    attr_reader :fields
    attr_reader :restrictions

    # @param title [String]
    # @param fields [Array<Metadata::Field>]
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

      # Searches for a TIND record matching any one of several MARC lookup keys
      #
      # @param key [Metadata::Key] The key to look up
      # @return [Metadata::Record] The first record found
      # @raise [ActiveRecord::RecordNotFound] if the record could not be found
      def find(key)
        return find_tind(key.bib_number) if key.source == Source::TIND
        return find_millennium(key.bib_number) if key.source == Source::MILLENNIUM

        raise ArgumentError, "Unsupported metadata source: #{key.source}"
      end

      # Searches for a TIND record matching the specified MARC lookup key
      #
      # @param bib_number [String] The bib number to look up
      # @return [Metadata::Record] The record
      # @raise [ActiveRecord::RecordNotFound] if the record could not be found
      def find_tind(bib_number)
        raise ArgumentError, "#{bib_number} is not a string" unless bib_number.is_a?(String)

        marc_record = Tind.find_marc_record(bib_number)
        raise ActiveRecord::RecordNotFound, "No TIND record found for bib number #{bib_number}" unless marc_record

        factory.from_marc(marc_record)
      end

      # Searches for the specified Millennium record and wraps it to look like a TIND record.
      #
      # @param bib_number [String] The Millennium bib number to find
      # @return [Metadata::Record] The record
      # @raise [ActiveRecord::RecordNotFound] if the record could not be found
      def find_millennium(bib_number)
        raise ArgumentError, "#{bib_number} is not a string" unless bib_number.is_a?(String)

        marc_record = Millennium.find_marc_record(bib_number)
        raise ActiveRecord::RecordNotFound, "No Millennium record found for bib number #{bib_number}" unless marc_record

        factory.from_marc(marc_record)
      end

      def factory
        @factory ||= begin
          json_config_path = File.join(Rails.root, 'config/tind/tind_html_metadata_da.json')
          json_config = File.read(json_config_path)
          json = JSON.parse(json_config)
          RecordFactory.from_json(json)
        end
      end

      private

      def log
        Rails.logger
      end

      def find_quietly(metadata_key)
        Tind.find_marc_record(metadata_key)
      rescue ActiveRecord::RecordNotFound => e
        log.trace("Ignoring #{e} in find_quietly(#{metadata_key})")
        nil
      end
    end
  end
end

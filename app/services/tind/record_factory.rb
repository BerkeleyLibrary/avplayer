require 'marc'
require 'tind/field'
require 'tind/record'

module Tind
  class RecordFactory
    CREATOR_PERSONAL = FieldFactory.new(label: 'Creator', marc_tag: '700%%', order: 2)
    CREATOR_CORPORATE = FieldFactory.new(label: 'Creator', marc_tag: '710%%', order: 2)
    LINKS_HTTP = FieldFactory.new(label: 'Linked Resources', marc_tag: '85641', order: 11)
    DEFAULT_FIELDS = [CREATOR_PERSONAL, CREATOR_CORPORATE, LINKS_HTTP].freeze

    # @return [Array<FieldFactory>] the configured fields
    attr_reader :field_factories

    # @param fields [Array<FieldFactory>] the configured fields
    def initialize(fields)
      @field_factories = fields.freeze
    end

    # @param marc_record [MARC::Record]
    def create_record_from_marc(marc_record)
      fields = fields_from(marc_record)
      return if fields.empty?

      title_field = fields.first { |f| f.tag == '245' }
      title = (title_field && title_field.lines.first) || '(Unknown title)'
      Tind::Record.new(title: title, fields: fields)
    end

    def create_record_from_xml(marc_xml)
      input = StringIO.new(marc_xml)
      marc_record = MARC::XMLReader.new(input).first
      return unless marc_record

      # noinspection RubyYardParamTypeMatch
      create_record_from_marc(marc_record)
    end

    class << self
      def from_json(json)
        fields = *DEFAULT_FIELDS
        json['config'].each do |json_field|
          next unless json_field['visible']

          field = FieldFactory.from_json(json_field)
          fields << field if field
        end

        fields.sort!

        unique_fields = []

        fields.each do |f|
          unique_fields << f unless unique_fields.any? { |u| u.same_field?(f) }
        end

        RecordFactory.new(unique_fields)
      end
    end

    private

    def fields_from(marc_record)
      field_factories.map { |f| f.create_field(marc_record) }.compact
    end
  end
end

require 'marc'

module Metadata
  class RecordFactory
    TITLE = FieldFactory.new(label: 'Title', marc_tag: '245%%', order: 1, subfield_order: 'a')
    DESCRIPTION = FieldFactory.new(label: 'Description', marc_tag: '520%%', order: 2, subfield_order: 'a')
    CREATOR_PERSONAL = FieldFactory.new(label: 'Creator', marc_tag: '700%%', order: 2)
    CREATOR_CORPORATE = FieldFactory.new(label: 'Creator', marc_tag: '710%%', order: 2)
    LINKS_HTTP = FieldFactory.new(label: 'Linked Resources', marc_tag: '85641', order: 11)
    DEFAULT_FIELDS = [TITLE, DESCRIPTION, CREATOR_PERSONAL, CREATOR_CORPORATE, LINKS_HTTP].freeze

    # @return [Array<FieldFactory>] the configured fields
    attr_reader :field_factories

    # @param fields [Array<FieldFactory>] the configured fields
    def initialize(fields)
      @field_factories = fields.freeze
    end

    # @param marc_record [MARC::Record]
    def from_marc(marc_record)
      fields = fields_from(marc_record)
      return if fields.empty?

      title_field = fields.find { |f| f.tag == '245' }
      title = title_from(title_field)

      description_field = fields.find { |f| f.tag == '520' }
      description = description_field && description_field.lines.join("\n")

      # TODO: check restrictions here

      Metadata::Record.new(title: title, description: description, fields: fields, restrictions: restrictions_from(marc_record))
    end

    class << self
      def from_json(json)
        fields = *DEFAULT_FIELDS
        json['config'].each do |json_field|
          next unless json_field['visible']

          # Suppress extra title field in favor of RecordFactory::TITLE
          next if json_field['machine_name'] == 'local_245_880_linking'

          field = FieldFactory.from_json(json_field)
          fields << field if field
        end

        unique_fields = find_uniques(fields)
        RecordFactory.new(unique_fields)
      end

      private

      def find_uniques(fields)
        unique_fields = []
        fields.sort.each do |f|
          next if unique_fields.any? { |u| u.same_field?(f) }

          unique_fields << f
        end
        unique_fields
      end
    end

    private

    def title_from(title_field)
      return Record::UNKNOWN_TITLE unless title_field

      title_field.lines.first
    end

    def fields_from(marc_record)
      field_factories.map { |f| f.create_field(marc_record) }.compact
    end

    def restrictions_from(marc_record)
      marc_record.each_by_tag('856') do |marc_field|
        subfield_y = marc_field['y']
        next unless subfield_y
        return Restrictions::UCB_IP if subfield_y.include?('UCB access')
      end
      Restrictions::PUBLIC
    end
  end
end

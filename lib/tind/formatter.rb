require 'marc'

module TIND
  class Formatter

    CREATOR_PERSONAL = Field.new(label: 'Creator', marc_tag: '700%%', order: 2)
    CREATOR_CORPORATE = Field.new(label: 'Creator', marc_tag: '710%%', order: 2)
    LINKS_HTTP = Field.new(label: 'Linked Resources', marc_tag: '85641', order: 11)
    DEFAULT_FIELDS = [CREATOR_PERSONAL, CREATOR_CORPORATE, LINKS_HTTP].freeze


    # @return [Array<Field>] the configured fields
    attr_reader :fields

    # @param fields [Array<Field>] the configured fields
    def initialize(fields)
      @fields = fields.freeze
    end

    # @param marc_record [MARC::Record]
    def to_hash(marc_record)
      result = {}
      fields.each do |f|
        values = f.values_from(marc_record)
        next if values.empty?

        label = f.label
        if (current = result[label])
          current.concat(values)
        else
          result[label] = values
        end
      end
      result
    end

    class << self
      def from_json(json)
        fields = *DEFAULT_FIELDS
        json['config'].each do |json_field|
          next unless json_field['visible']

          field = Field.from_json(json_field)
          fields << field if field
        end

        fields.sort!

        unique_fields = []

        fields.each do |f|
          unique_fields << f unless unique_fields.any? { |u| u.same_field?(f) }
        end

        Formatter.new(unique_fields)
      end
    end
  end

end

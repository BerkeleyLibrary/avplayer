require 'marc'

module TIND
  class Field
    TAG_RE = /([0-9]{3})([a-z0-9%])([a-z0-9%])([a-z0-9%]?)/

    attr_reader :tag, :ind1, :ind2, :subfield, :subfield_order

    def initialize(marc_tag:, subfield_order: nil)
      md = TAG_RE.match(marc_tag)
      @tag = md[1]
      @ind1 = Field.indicator(md[2])
      @ind2 = Field.indicator(md[3])
      @subfield = md[4] unless md[4].blank?
      @subfield_order = subfield_order ? subfield_order.split(',') : nil
    end

    # Finds the values for this MARC query in a MARC record.
    # @param marc_record [MARC::Record]
    # @return [Array<String>, Array<Hash{String => String}>]
    def values_from(marc_record)
      values = []
      marc_record.each_by_tag(tag) do |field|
        value = value_from(field)
        values << value if value
      end
      values
    end

    # @param data_field MARC::DataField
    # @return [String, Hash{String => String}, nil]
    def value_from(data_field)
      raise ArgumentError, "Field has wrong tag: expected #{tag}, was #{data_field.tag}" unless tag == data_field.tag
      return if ind_1 && ind_1 != data_field.indicator1
      return if ind_2 && ind_2 != data_field.indicator2
      return data_field[subfield] if subfield

      subfield_values = subfield_order.map do |code|
        subfield_value = data_field[subfield]
        [code, subfield_value] if subfield_value
      end.compact
      return subfield_values.to_h unless subfield_values.empty?

      all_subfield_values = data_field.subfields.map do |sf|
        [sf.code, sf.value]
      end
      all_subfield_values.to_h unless all_subfield_values.empty?
    end

    class << self
      def indicator(ind_char)
        ind_char if ind_char && ind_char != '%' && ind_char != '_'
      end
    end
  end
end

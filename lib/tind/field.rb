require 'marc'

module TIND
  class Field
    include Comparable

    TAG_RE = /([0-9]{3})([a-z0-9_%])([a-z0-9_%])([a-z0-9_%]?)/.freeze

    ATTRS = %i[order tag ind_1 ind_2 subfield label subfields_separator subfield_order].freeze
    FIELD_LOOKUP_ATTRS = (ATTRS - [:order, :label]).freeze

    ATTRS.each { |attr| attr_reader attr }

    # TODO: something smarter than subfields_separator (typed values?)
    def initialize(order:, marc_tag:, label:, subfields_separator: ' ', subfield_order: nil)
      md = TAG_RE.match(marc_tag)
      raise ArgumentError, "Invalid MARC tag #{marc_tag}" unless md

      @tag = md[1]
      @ind_1 = Field.indicator(md[2])
      @ind_2 = Field.indicator(md[3])

      subfield = md[4]
      @subfield = subfield unless subfield.blank? || subfield == '%'

      @subfield_order = subfield_order && !subfield_order.blank? ? subfield_order.split(',') : nil

      @label = label
      @subfields_separator = subfields_separator
      @order = order
    end

    # @param other [Field]
    def <=>(other)
      return unless other
      return 0 if equal?(other)

      (ATTRS - [:subfield_order]).each do |attr|
        return nil unless other.respond_to?(attr)

        v1 = send(attr)
        v2 = other.send(attr)

        next unless v1 != v2
        return 1 if v1.nil?
        return -1 if v2.nil?

        return v1 < v2 ? -1 : 1
      end

      s1 = subfield_order&.join
      s2 = other.subfield_order&.join

      if s1 != s2
        return 1 if s1.nil?
        return -1 if s2.nil?

        return s1 < s2 ? -1 : 1
      end

      0
    end

    def to_h
      ATTRS.map do |attr|
        [attr, self.send(attr)]
      end.to_h
    end

    def to_s
      attr_vals = TIND::Field::ATTRS.map do |attr|
        "#{attr}: #{self.send(attr).inspect}"
      end.join(', ')

      "#<#{self.class.name}: #{attr_vals}>"
    end

    # @return [Boolean] true if this represents the same MARC tag/field/subfields as the specified other, false otherwise
    def same_field?(other)
      FIELD_LOOKUP_ATTRS.each do |attr|
        return false unless other.respond_to?(attr)
        v1 = self.send(attr)
        v2 = other.send(attr)
        return false if v1 != v2
      end
      true
    end

    # Finds the values for this MARC query in a MARC record.
    # @param marc_record [MARC::Record]
    # @return [Array<String>]
    def values_from(marc_record)
      values = []
      marc_record.each_by_tag(tag) do |field|
        value = value_from(field)
        values << value if value
      end
      values
    end

    # @param data_field MARC::DataField
    # @return [String, nil]
    def value_from(data_field)
      raise ArgumentError, "Field has wrong tag: expected #{tag}, was #{data_field.tag}" unless tag == data_field.tag
      return if ind_1 && ind_1 != data_field.indicator1
      return if ind_2 && ind_2 != data_field.indicator2
      return data_field[subfield] if subfield

      subfield_values = if subfield_order
                          subfield_order.map { |code| data_field[code] }.compact
                        else
                          data_field.subfields.map(&:value)
                        end
      subfield_values.join(subfields_separator) unless subfield_values.empty?
    end

    class << self
      def indicator(ind_char)
        ind_char if ind_char && ind_char != '%' && ind_char != '_'
      end

      def from_json(json_field)
        params = json_field['params']
        return unless params

        labels = json_field['labels']
        return unless labels

        label_en = labels['en']
        return unless label_en

        marc_tag = find_marc_tag(json_field)
        return unless marc_tag

        Field.new(
          order: json_field['order'],
          marc_tag: marc_tag,
          label: label_en,
          subfields_separator: params['subfields_separator'],
          subfield_order: params['subfield_order']
        )
      end

      def find_marc_tag(json)
        params = json['params']

        if (tag = params['tag'])
          return tag unless tag.blank?
        end

        if (fields = params['fields'])
          return fields unless fields.blank?
        end

        if (tag = params['tag_1'])
          return tag unless tag.blank?
        end

        if (tag = params['tag_2'])
          return tag unless tag.blank?
        end

        if (input_tag = params['input_tag'])
          return "#{input_tag}#{params['input_subfield']}"
        end

        nil
      end

    end
  end
end

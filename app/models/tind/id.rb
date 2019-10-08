module Tind
  class Id
    MARC_FIELD_RE = /^([0-9]{3})([a-z0-9])$/.freeze

    attr_reader :tag
    attr_reader :subfield
    attr_reader :value

    def initialize(field:, value:)
      match_data = MARC_FIELD_RE.match(field)
      raise ArgumentError, "MARC field '#{field}' must be in format XXXx" unless match_data

      @tag = match_data[1]
      @subfield = match_data[2]
      @value = value
    end

    def to_s
      "#{tag}#{subfield}: #{value}"
    end

    # @param marc_record [MARC::Record]
    # @return [Boolean] true if this ID is in the MARC record, false otherwise
    def in?(marc_record)
      return unless marc_record

      marc_record.each_by_tag(tag) { |field| return true if field[subfield] == value }
      false
    end

    def ==(other)
      return true if equal?(other)
      return false unless other
      return false unless other.is_a?(Id)
      return false unless other.tag == tag
      return false unless other.subfield == subfield

      other.value == value
    end

    def hash
      [tag, subfield, value].reduce(0) do |r, v|
        v.hash + (r << 5) - r
      end
    end

  end
end

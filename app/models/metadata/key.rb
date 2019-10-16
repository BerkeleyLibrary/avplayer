module Metadata
  class Key

    attr_reader :source
    attr_reader :bib_number
    attr_reader :tind_id

    # @param source [Source]
    # @param bib_number [String, nil]
    # @param tind_id [Integer, nil]
    def initialize(source:, bib_number: nil, tind_id: nil)
      raise ArgumentError, 'Source cannot be nil' unless source

      raise ArgumentError, 'Millennium source requires bib_number' unless bib_number || source != Source::MILLENNIUM
      raise ArgumentError, 'TIND source requires tind_id' unless tind_id || source != Source::TIND

      @source = source
      @bib_number = bib_number
      @tind_id = tind_id
    end

    def to_s
      "#{source.value}:#{bib_number}"
    end

    def ==(other)
      return true if equal?(other)
      return false unless other
      return false unless other.is_a?(Key)
      return false unless other.source == source
      return false unless other.bib_number == bib_number

      other.tind_id == tind_id
    end

    def hash
      [source, bib_number, tind_id].reduce(0) do |r, v|
        v.hash + (r << 5) - r
      end
    end

  end
end

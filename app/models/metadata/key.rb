module Metadata
  class Key

    attr_reader :source
    attr_reader :bib_number

    # @param bib_number [String]
    # @param source [Source]
    def initialize(source:, bib_number:)
      @bib_number = bib_number
      @source = source
    end

    def to_s
      "#{source.value}:#{bib_number}"
    end

    def ==(other)
      return true if equal?(other)
      return false unless other
      return false unless other.is_a?(Key)
      return false unless other.source == source

      other.bib_number == bib_number
    end

    def hash
      [source, bib_number].reduce(0) do |r, v|
        v.hash + (r << 5) - r
      end
    end

  end
end

module Tind
  class Record

    attr_reader :title
    attr_reader :fields

    # @param title [String]
    # @param fields [Array<Tind::Field>]
    def initialize(title:, fields:)
      @title = title
      @fields = fields
    end
  end
end

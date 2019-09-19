module Tind
  class Field
    attr_reader :tag
    attr_reader :label

    def initialize(tag:, label:)
      @tag = tag
      @label = label
    end
  end

  class TextField < Field
    attr_reader :lines

    def initialize(tag:, label:, lines:)
      super(tag: tag, label: label)
      @lines = lines
    end
  end

  class LinkField < Field
    attr_reader :links

    def initialize(tag:, label:, links:)
      super(tag: tag, label: label)
      @links = links
    end
  end

  class Link
    attr_reader :body
    attr_reader :url

    def initialize(body:, url:)
      @body = body
      @url = url
    end
  end
end

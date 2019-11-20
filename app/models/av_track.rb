class AvTrack
  include Comparable

  attr_reader :sort_order, :title, :file

  delegate(:path, to: :file)

  def initialize(sort_order:, title: nil, file:)
    @sort_order = sort_order
    @title = title || "Part #{sort_order}"
    @file = file
  end

  def <=>(other)
    return 0 if equal?(other)

    order = sort_order <=> other.sort_order
    return order if order != 0

    order = title <=> other.title
    return order if order != 0

    path <=> other.path
  end
end
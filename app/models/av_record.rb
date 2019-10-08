require 'active_record/errors'
require 'tind/id'
require 'tind/record'

class AvRecord
  attr_reader :collection, :files, :tind_ids, :tind_record

  def initialize(collection:, files:, tind_ids:)
    @collection = collection
    @files = files
    @tind_ids = tind_ids
    @tind_record = Tind::Record.find_any(tind_ids)
  end

  def title
    tind_record.title
  end
end

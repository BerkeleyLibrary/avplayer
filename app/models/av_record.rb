require 'active_record/errors'
require 'tind/marc_lookup'
require 'tind/record'

class AvRecord
  attr_reader :collection, :files, :marc_lookups, :tind_record

  def initialize(collection:, files:, marc_lookups:)
    @collection = collection
    @files = files
    @marc_lookups = marc_lookups
    @tind_record = Tind::Record.find_any(marc_lookups)
  end

  def title
    tind_record.title
  end
end

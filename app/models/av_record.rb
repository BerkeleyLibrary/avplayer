require 'active_record/errors'
require 'tind/id'
require 'tind/record'

class AvRecord
  attr_reader :collection, :files, :tind_ids

  def initialize(collection:, files:, tind_ids:)
    @collection = collection
    @files = files
    @tind_ids = tind_ids
  end

  def title
    tind_record.title
  end

  def tind_record
    @tind_record ||= find_tind_record
  end

  private

  def find_tind_record
    Tind::Record.find_any(tind_ids)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn(e)
    return Tind::Record::NONE
  end
end

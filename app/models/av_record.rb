require 'active_record/errors'
require 'metadata/key'
require 'metadata/record'

class AvRecord
  attr_reader :files, :metadata_key, :metadata_record

  # Initializes a new AV record.
  #
  # @param files [Array<AvFile>] The AV files
  # @param metadata_key [Key] The metadata lookup key
  def initialize(files:, metadata_key:)
    @files = files
    @metadata_record = Metadata::Record.find(metadata_key)
    @metadata_key = metadata_key
  end

  # Gets the title of this record.
  #
  # @return [String] The title.
  def title
    metadata_record.title
  end

  # Gets the access restrictions for this record.
  #
  # @return [Restrictions] The restrictions.
  def restrictions
    metadata_record.restrictions
  end

  # @return [Boolean] True if public, false otherwise
  def public?
    restrictions == Restrictions::PUBLIC
  end
end

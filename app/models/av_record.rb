require 'active_record/errors'
require 'metadata/key'
require 'metadata/record'

class AvRecord
  attr_reader :files, :marc_lookups, :metadata_record

  # Initializes a new AV record.
  #
  # @param files [Array<AvFile>] The AV files
  # @param marc_lookups [Array<Metadata::Key>] The MARC lookup keys
  def initialize(files:, marc_lookups:)
    @files = files
    @marc_lookups = marc_lookups
    # TODO: support looking up Millennium records
    @metadata_record = Metadata::Record.find_any(marc_lookups)
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

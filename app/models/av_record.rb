require 'active_record/errors'
require 'tind/marc_lookup'
require 'tind/record'

class AvRecord
  attr_reader :files, :marc_lookups, :tind_record

  # Initializes a new AV record.
  #
  # @param files [Array<AvFile>] The AV files
  # @param marc_lookups [Array<Tind::MarcLookup>] The MARC lookup keys
  def initialize(files:, marc_lookups:)
    @files = files
    @marc_lookups = marc_lookups
    # TODO: support looking up Millennium records
    @tind_record = Tind::Record.find_any(marc_lookups)
  end

  # Gets the title of this record.
  #
  # @return [String] The title.
  def title
    tind_record.title
  end

  # Gets the access restrictions for this record.
  #
  # @return [Tind::Restrictions] The restrictions.
  def restrictions
    tind_record.restrictions
  end

  # @return [Boolean] True if public, false otherwise
  def public?
    restrictions == Tind::Restrictions::PUBLIC
  end
end

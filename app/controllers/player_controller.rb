require 'nokogiri'
require 'marc'
require 'rest-client'

class PlayerController < ApplicationController
  # TODO: make TIND location configurable
  TIND_SEARCH_URL = 'https://digicoll.lib.berkeley.edu/search'.freeze
  TIND_ID_PARAMS = %w[901m 901o].freeze
  MARC_FIELD_RE = /^([0-9]{3})([a-z])$/.freeze

  def show
    @collection = player_params[:collection]
    @files = split_files(player_params[:files])
    @tind_ids = tind_ids(player_params)
    @marc_record = tind_marc_record(@tind_ids)
  end

  private

  def player_params
    @player_params ||= begin
      # :format is a default parameter added from routes.rb
      permitted = %i[collection files format] + TIND_ID_PARAMS
      params.permit(*permitted)
    end
  end

  # @param files_param a semicolon-delimited (%3B-delimited in the URL) list of files
  def split_files(files_param)
    return [] unless files_param

    files_param.split(';')
  end

  def tind_ids(params)
    params.to_h.find_all do |k, _|
      # TODO: validate/sanitize value
      k.to_s =~ MARC_FIELD_RE
    end.to_h
  end

  def tind_marc_record(tind_ids)
    tind_ids.each do |param, id|
      field, subfield = field_and_subfield(param)

      resp = RestClient.get(TIND_SEARCH_URL, params: { p: id, of: 'xm' })
      next unless resp.code == 200

      # TODO: stream response https://github.com/rest-client/rest-client#streaming-responses
      MARC::XMLReader.new(StringIO.new(resp.body)).each do |record|
        return record if record[field][subfield] == id
      end
    end
    # TODO: something more appropriate (maybe just log it? display an error?)
    raise ActiveRecord::RecordNotFound("No TIND record found for IDs: #{tind_ids}", MARC::Record, tind_ids.keys, tind_ids.values)
  end

  def field_and_subfield(param)
    match_data = MARC_FIELD_RE.match(param)
    [1, 2].map { |i| match_data[i] }
  end
end

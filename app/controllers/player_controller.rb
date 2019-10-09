require 'health'
require 'tind/marc_lookup'

class PlayerController < ApplicationController

  TIND_ID_PARAMS = %w[901m 901o].freeze
  MARC_FIELD_RE = /^([0-9]{3})([a-z])$/.freeze

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show
    av_record = AvRecord.new(
      collection: player_params[:collection],
      files: split_files(player_params[:files]),
      marc_lookups: marc_lookups(player_params)
    )
    render locals: {
      record: av_record
    }
  end

  def record_not_found
    render :record_not_found, status: 404, locals: {
      marc_lookups: marc_lookups(player_params)
    }
  end

  def health
    check = Health::Check.new
    render json: check, status: check.http_status_code
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

  def marc_lookups(params)
    TIND_ID_PARAMS.map do |p|
      value = params[p]
      Tind::MarcLookup.new(field: p, value: value) if value
    end.compact
  end
end

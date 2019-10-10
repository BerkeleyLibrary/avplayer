require 'health'
require 'tind/marc_lookup'

class PlayerController < ApplicationController

  TIND_ID_PARAMS = %w[901m 901o].freeze
  MARC_FIELD_RE = /^([0-9]{3})([a-z])$/.freeze

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show
    av_record = AvRecord.new(
      files: av_files,
      marc_lookups: marc_lookups(player_params)
    )

    # TODO: actual IP restriction
    raise ActiveRecord::RecordNotFound unless av_record.public?

    render locals: { record: av_record }
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

  def av_files
    paths.map { |path| AvFile.new(collection: collection, path: path) }
  rescue ArgumentError => e
    log.warn("Error parsing path parameters: #{paths}", e)
    raise ActiveRecord::RecordNotFound
  end

  def collection
    @collection = player_params[:collection]
  end

  def paths
    @paths ||= split_paths(player_params[:paths])
  end

  def player_params
    @player_params ||= begin
      # :format is a default parameter added from routes.rb
      permitted = %i[collection paths format] + TIND_ID_PARAMS
      params.permit(*permitted)
    end
  end

  # @param paths_param a semicolon-delimited (%3B-delimited in the URL) list of paths
  def split_paths(paths_param)
    return [] unless paths_param

    paths_param.split(';')
  end

  def marc_lookups(params)
    TIND_ID_PARAMS.map do |p|
      value = params[p]
      Tind::MarcLookup.new(field: p, value: value) if value
    end.compact
  end
end

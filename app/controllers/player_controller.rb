require 'active_record'
require 'health'
require 'metadata/key'

class PlayerController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request

  def show
    av_record = AvRecord.new(
      files: av_files,
      metadata_key: metadata_key
    )

    # Until we have everything migrated to Wowza and we're using
    # secure tokens, it's safest just to never expose the URLs.
    raise ActiveRecord::RecordNotFound unless av_record.public?

    render locals: { record: av_record }
  end

  def record_not_found
    render :record_not_found, status: 404, locals: {
      collection: collection,
      paths: paths,
      record_id: record_id
    }
  end

  def bad_request(e)
    log.error(e)
    render :bad_request, status: 400
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

  def player_params
    @player_params ||= begin
      required = %i[collection paths record_id]

      # :format is a default parameter added from routes.rb
      permitted_params = params.permit(required + %i[format])

      # You'd think require() would behave like permit(), but you'd be wrong
      values = required.map do |k|
        [k, permitted_params.require(k)]
      end.to_h
      ActionController::Parameters.new(values)
    end
  end

  def collection
    @collection = player_params[:collection]
  end

  def paths
    @paths ||= split_paths(player_params[:paths])
  end

  def metadata_key
    @metadata_key ||= parse_metadata_key
  end

  def record_id
    @record_id = player_params[:record_id]
  end

  # @param paths_param a semicolon-delimited (%3B-delimited in the URL) list of paths
  def split_paths(paths_param)
    return [] unless paths_param

    paths_param.split(';')
  end

  def parse_metadata_key
    source_val, id_value = record_id.split(':')
    raise ActionController::ParameterMissing, "No ID value found in record_id '#{record_id}'" unless id_value

    source = Metadata::Source.find_by_value(source_val)
    return Metadata::Key.new(source: source, bib_number: id_value) if source == Metadata::Source::MILLENNIUM
    return Metadata::Key.new(source: source, tind_id: parse_tind_id(id_value)) if source == Metadata::Source::TIND

    raise ActionController::ParameterMissing, "Unknown metadata source '#{source_val}' in record_id '#{record_id}'"
  end

  def parse_tind_id(id_value)
    raise ActionController::ParameterMissing, "Invalid TIND ID '#{id_value}'" unless id_value.match(/^\d+$/)

    id_value.to_i
  end
end

require 'active_record'
require 'av/core'
require 'health/check'
require 'av_player/record_not_available'

class PlayerController < ApplicationController

  rescue_from AV::RecordNotFound, with: :record_not_found
  rescue_from AvPlayer::RecordNotAvailable, with: :record_not_available
  rescue_from ActionController::ParameterMissing, with: :bad_request

  def show
    render locals: { record: load_record }
  end

  def record_not_found(exception)
    logger.warn(exception) if exception

    render :record_not_found, status: :not_found, locals: {
      collection: collection,
      record_id: record_id
    }
  end

  def record_not_available(exception)
    logger.warn(exception) if exception

    render :record_not_available, status: :forbidden, locals: {
      collection: collection,
      record_id: record_id
    }
  end

  def health
    check = Health::Check.new
    render json: check, status: check.http_status_code
  end

  def preview
    render locals: { tracks: preview_tracks }
  end

  def bad_request(exception)
    logger.debug(exception) if exception

    head :bad_request
  end

  private

  def preview_tracks
    collection = preview_params[:collection]
    relative_path = preview_params[:relative_path]
    raise ActionController::ParameterMissing unless relative_path

    relative_path.split(';').each_with_index.map do |rp, index|
      AV::Track.new(sort_order: index, path: "#{collection}/#{rp}")
    end
  end

  def load_record
    record = AV::Record.from_metadata(collection: collection, record_id: record_id)
    return record unless record.ucb_access?
    return record if ucb_request?

    raise AvPlayer::RecordNotAvailable, "Record #{record_id.inspect} is UCB access only"
  end

  def preview_params
    @preview_params ||= valid_params(:collection, :relative_path)
  end

  def player_params
    @player_params ||= valid_params(:collection, :record_id)
  end

  def valid_params(*required_params)
    params.tap do |pp|
      # :format is a default parameter added from routes.rb
      # TODO: do we still need this?
      pp.permit(required_params + %i[format])
      required_params.each { |p| pp.require(p) }
    end
  end

  def collection
    @collection ||= player_params[:collection]
  end

  def record_id
    @record_id ||= player_params[:record_id]
  end

end

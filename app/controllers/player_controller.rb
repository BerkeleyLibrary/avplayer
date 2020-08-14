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
    render locals: { track: preview_track }
  end

  def bad_request(exception)
    logger.debug(exception) if exception

    head :bad_request
  end

  private

  def preview_track
    collection = preview_params[:collection]
    relative_path = preview_params[:relative_path]
    raise ActionController::ParameterMissing unless relative_path

    AV::Track.new(sort_order: 0, path: "#{collection}/#{relative_path}")
  end

  def load_record
    record = AV::Record.from_metadata(collection: collection, record_id: record_id)
    return record unless record.ucb_access?
    return record if UcbIpService.ucb_request?(request)

    raise AvPlayer::RecordNotAvailable, "Record #{record_id.inspect} is UCB access only"
  end

  # TODO: collapse to one params method
  def preview_params
    @preview_params ||= begin
      required = %i[collection relative_path]

      # :format is a default parameter added from routes.rb
      permitted_params = params.permit(required + %i[format])

      # You'd think require() would behave like permit(), but you'd be wrong
      values = required.map do |k|
        [k, permitted_params.require(k)]
      end.to_h
      ActionController::Parameters.new(values)
    end
  end

  # TODO: collapse to one params method
  def player_params
    @player_params ||= begin
      required = %i[collection record_id]

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
    @collection ||= player_params[:collection]
  end

  def record_id
    @record_id ||= player_params[:record_id]
  end

end

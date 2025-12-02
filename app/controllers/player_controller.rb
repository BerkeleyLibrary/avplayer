require 'active_record'
require 'berkeley_library/av/core'

class PlayerController < ApplicationController

  rescue_from BerkeleyLibrary::AV::RecordNotFound, with: :record_not_found
  rescue_from Error::AccessRestricted, with: :access_restricted
  rescue_from ActionController::ParameterMissing, with: :bad_request

  def show
    ensure_record_available!

    render locals: { record: }
  end

  def record_not_found(exception)
    logger.warn(exception) if exception

    render :record_not_found, status: :not_found, locals: {
      collection:,
      record_id:
    }
  end

  def access_restricted(exception)
    logger.warn(exception) if exception

    ex_record = exception.respond_to?(:record) ? exception.record : nil

    render :access_restricted, status: :forbidden, locals: {
      collection:,
      record_id:,
      record: ex_record
    }
  end

  def preview
    render locals: { tracks: preview_tracks }
  end

  def bad_request(exception)
    logger.debug(exception) if exception

    head :bad_request
  end

  private

  def record
    @record ||= BerkeleyLibrary::AV::Record.from_metadata(collection:, record_id:)
  end

  def ensure_record_available!
    return if authorized?

    raise(Error::AccessRestricted, record) if record.calnet_only?
    raise(Error::AccessRestricted, record) if record.calnet_or_ip? && external_request?
  end

  def preview_tracks
    collection = preview_params[:collection]
    relative_path = preview_params[:relative_path]
    raise ActionController::ParameterMissing unless relative_path

    relative_path.split(';').each_with_index.map do |rp, index|
      BerkeleyLibrary::AV::Track.new(sort_order: index, path: "#{collection}/#{rp}")
    end
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

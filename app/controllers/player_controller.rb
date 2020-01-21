require 'active_record'
require 'av/core'
require 'health/check'

class PlayerController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request

  def show
    record = load_record

    render locals: { record: record }
  rescue AV::RecordNotFound => e
    raise ActiveRecord::RecordNotFound.new(e.message, AV::Record, record_id)
  end

  def record_not_found
    render :record_not_found, status: 404, locals: {
      collection: collection,
      record_id: record_id
    }
  end

  def health
    check = Health::Check.new
    render json: check, status: check.http_status_code
  end

  private

  def load_record
    record = AV::Record.from_metadata(collection: collection, record_id: record_id)
    return record unless record.ucb_access?

    # Until we have everything migrated to Wowza and we're using
    # secure tokens, it's safest just to never expose the URLs.
    raise ActiveRecord::RecordNotFound
  end

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

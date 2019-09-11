class PlayerController < ApplicationController
  TIND_ID_PARAMS = %w[901m 901o].freeze

  def index
    @collection = params[:collection]
    @files = split_files(params[:files])
    @tind_ids = tind_ids(params)
  end

  private

  # @param files_param a semicolon-delimited (%3B-delimited in the URL) list of files
  def split_files(files_param)
    return [] unless files_param

    files_param.split(';')
  end

  def tind_ids(params)
    tind_params = params.permit(*TIND_ID_PARAMS)
    tind_params.to_h.find_all do |k, _|
      k.to_s =~ /^[0-9]{3}[a-z]$/
    end.to_h
  end

end

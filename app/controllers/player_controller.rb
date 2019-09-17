class PlayerController < ApplicationController
  TIND_ID_PARAMS = %w[901m 901o].freeze

  def show
    @collection = player_params[:collection]
    @files = split_files(player_params[:files])
    @tind_ids = tind_ids(player_params)
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
      k.to_s =~ /^[0-9]{3}[a-z]$/
    end.to_h
  end

  def tind_marc_xml(tind_ids)
    tind_ids.each do |field, id|
      # TODO: make TIND location configurable
      url = "https://digicoll.lib.berkeley.edu/search?p=#{id}&of=xm"

      # TODO: get XML
      #   - iterate over <record/> tags
      #   - validate field & subfield
      #   - return first match
    end
  end
end

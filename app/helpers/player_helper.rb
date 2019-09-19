module PlayerHelper
  def wowza_url_for(collection:, file:)
    # TODO: support different file types
    "http://vm147.lib.berkeley.edu:1935/#{collection}/mp3:#{file}/playlist.m3u8"
  end

  def wowza_base_url
    Rails.application.config.wowza_base_url
  end
end

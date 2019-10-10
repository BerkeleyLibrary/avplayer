require 'typesafe_enum'

class AvFileType < TypesafeEnum::Base

  new(:MP3, 'mp3') do
    def mime_type
      'application/x-mpegURL'
    end
  end

  new(:MP4, 'mp4') do
    def mime_type
      'video/mp4'
    end
  end

  def extension
    ".#{value}"
  end

  class << self
    # @param path [String]
    # @return [AvFileType, nil] The file type, or nil if it cannot be determined
    def for_path(path)
      raise ArgumentError, "Can't determine type of nil path" unless path

      AvFileType.each { |t| return t if path.end_with?(t.extension) }
      nil
    end
  end
end

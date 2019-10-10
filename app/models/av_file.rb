class AvFile
  PATH_FORMATTERS_BY_TYPE = {
    AvFileType::MP3 => :mp3_path,
    AvFileType::MP4 => :mp4_path
  }.freeze

  # The file type
  # @return [AvFileType]
  attr_reader :type

  # The path to the file
  # @return [String]
  attr_reader :path

  # The collection
  # @return [String]
  attr_reader :collection

  def initialize(collection:, path:)
    @collection = AvFile.valid_collection(collection)
    @path = AvFile.valid_path(path)
    @type = AvFile.valid_type_from_path(path)
  end

  def streaming_url
    path_formatter = PATH_FORMATTERS_BY_TYPE[type]
    send(path_formatter)
  end

  def mime_type
    type.mime_type
  end

  private

  # TODO: find some path-joining code that's smart about //s

  def mp4_path
    "#{video_base_url}/#{path}".gsub(%r{(?<!:)//}, '/')
  end

  def mp3_path
    "#{wowza_base_url}/#{collection}/mp3:#{path}/playlist.m3u8".gsub(%r{(?<!:)//}, '/')
  end

  def wowza_base_url
    Rails.application.config.wowza_base_url
  end

  def video_base_url
    Rails.application.config.video_base_url
  end

  class << self

    def valid_collection(collection)
      raise ArgumentError, 'collection cannot be nil' unless collection

      collection
    end

    def valid_path(path)
      raise ArgumentError, 'Path cannot be nil' unless path

      path
    end

    # @return [AvFileType] The file type
    # @raise ArgumentError if a valid file type cannot be determined from the path
    def valid_type_from_path(path)
      raise ArgumentError, 'Path cannot be nil' unless path

      type = AvFileType.for_path(path)
      raise ArgumentError, "Unable to determine file type for path #{path}" unless type
      raise ArgumentError, "Unsupported file type #{type} for path #{path}" unless PATH_FORMATTERS_BY_TYPE.include?(type)

      type
    end
  end
end

require 'bindata'


module CaptionAmerica
  class InvalidTimestampError < StandardError; end
  class UnknownCaptionFormatError < StandardError; end
  class CaptionReaderNotImpementedError < StandardError; end
  class InvalidCaptionFileError < StandardError; end

  def self.read(filepath, type = nil)
    type = determine_type(filepath) if type.nil?

    reader = case type
    when :vtt, :webvtt
      WebVTT
    when :caption_maker, :captionmaker, :cap
      CaptionMaker
    when :dfxp
      DFXP
    else
      raise UnknownCaptionFormatError
    end

    reader.new(filepath).read
  end

private

  def self.determine_type(filepath)
    case File.extname(filepath.path.downcase)
    when ".cap"
      :cap
    when ".vtt"
      :vtt
    when ".dfxp"
      :dfxp
    end
  end
end

require 'caption_america/version'
require 'caption_america/hex_string_byte_buffer'
require 'caption_america/cue_time'
require 'caption_america/caption'
require 'caption_america/adapter'
require 'caption_america/adapters/caption_maker/caption_maker'
require 'caption_america/adapters/webvtt/webvtt'
require 'caption_america/adapters/dfxp/dfxp'

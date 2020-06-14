require 'bindata'


module CaptionAmerica
  class InvalidTimestampError < StandardError; end
  class UnknownCaptionFormatError < StandardError; end
  class CaptionReaderNotImpementedError < StandardError; end
  class InvalidCaptionFileError < StandardError; end

  def self.read(filepath, type)
    reader = case type
    when :vtt, :webvtt
      WebVTT
    when :caption_maker, :captionmaker, :cap
      CaptionMaker
    when :caption_maker_v8, :captionmaker_v8, :cap_v8
      CaptionMakerV8
    else
      raise UnknownCaptionFormatError
    end

    raise CaptionReaderNotImpementedError unless reader.respond_to? :read

    reader.read(filepath)
  end
end

require 'caption_america/version'
require 'caption_america/hex_string_byte_buffer'
require 'caption_america/cue_time'
require 'caption_america/caption'
require 'caption_america/adapters/caption_maker_v8/caption_maker_v8'
require 'caption_america/adapters/webvtt/webvtt'

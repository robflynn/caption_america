#
# Many Captions! Handle It!
#
module CaptionAmerica
  class InvalidTimestampError < StandardError; end
  class InvalidCaptionFormatError < StandardError; end

  def self.read(filepath, type)
    reader = case type
    when :vtt, :webvtt
      WebVTT
    else
      raise InvalidCaptionFormatError
    end

    contents
  end
end

require 'caption_america/version'
require 'caption_america/time_stone'
require 'caption_america/caption'

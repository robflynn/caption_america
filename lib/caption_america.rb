#
# Many Captions! Handle It!
#
module CaptionAmerica
  class InvalidTimestampError < StandardError; end
  class InvalidCaptionFormatError < StandardError; end
  class CaptionReaderNotImpementedError < StandardError; end

  module WebVTT
    def self.read(filepath)
      captions = []

      File.open(filepath).each do |line|
        puts line
      end

      captions
    end
  end

  def self.read(filepath, type)
    reader = case type
    when :vtt, :webvtt
      WebVTT
    else
      raise InvalidCaptionFormatError
    end

    raise CaptionReaderNotImpementedError unless reader.respond_to? :read

    reader.read(filepath)
  end
end

require 'caption_america/version'
require 'caption_america/cue_time.rb'
require 'caption_america/caption'

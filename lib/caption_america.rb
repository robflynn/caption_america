module CaptionAmerica
  class InvalidTimestampError < StandardError; end
  class UnknownCaptionFormatError < StandardError; end
  class CaptionReaderNotImpementedError < StandardError; end
  class InvalidCaptionFileError < StandardError; end

  def self.read(filepath, type = nil)
    type = determine_type_from_file(filepath) if type.nil?

    reader = case type
    when :vtt
      WebVTT
    when :cap
      CaptionMaker
    when :dfxp
      DFXP
    else
      raise UnknownCaptionFormatError
    end

    reader.new(filepath).read
  end

  def self.determine_type_from_file(file)
    # This far everything syncs up, add special cases here
    return :unknown if File.extname(file.path).empty?

    File.extname(file.path.downcase)[1..].to_sym
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

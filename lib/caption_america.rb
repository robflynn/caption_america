#
# Many Captions! Handle It!
#
module CaptionAmerica
  class InvalidTimestampError < StandardError; end

  def self.read(filepath)
    contents = File.read(filepath)

    contents
  end
end

require 'caption_america/version'
require 'caption_america/time_stone'
require 'caption_america/caption'

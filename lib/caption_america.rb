require 'bindata'


module CaptionAmerica
  class InvalidTimestampError < StandardError; end
  class InvalidCaptionFormatError < StandardError; end
  class CaptionReaderNotImpementedError < StandardError; end
  class InvalidCaptionFileError < StandardError; end

  module WebVTT
    def self.read(filepath)
      captions = []

      lines = File.read(filepath).split("\n")

      format_check = lines.shift

      if format_check != 'WEBVTT'
        raise InvalidCaptionFileError
      end

      header_done = false
      working_caption = nil

      while lines.count > 0
        line = lines.shift

        if header_done

          if working_caption
            if line == ''
              # tidy up
              working_caption.text.strip!

              captions << working_caption

              working_caption = nil
            else
              working_caption.text += line + "\n"
            end
          end

          if !working_caption && is_caption_block_header?(line)
            in_time, out_time = self.get_in_and_out_time(line)

            working_caption = Caption.new
            working_caption.in_time = in_time
            working_caption.out_time = out_time
          end
        else
          if line == ''
            header_done = true
          end
        end
      end


      captions << working_caption if working_caption

      captions
    end

private

    def self.is_caption_block_header?(line)
      return false unless line.include? "-->"

      tokens = line.split(/\s+/)

      # Must at least have an in and out point
      return false unless tokens.count >= 3

      in_time = CueTime.timestamp_match?(tokens[0])
      out_time = CueTime.timestamp_match?(tokens[2])

      true
    end

    def self.get_in_and_out_time(line)
      tokens = line.split(/\s+/)

      in_time = CueTime.parse(tokens[0])
      out_time = CueTime.parse(tokens[2])

      [in_time, out_time]
    end
  end

  def self.read(filepath, type)
    reader = case type
    when :vtt, :webvtt
      WebVTT
    when :caption_maker, :captionmaker, :cap
      CaptionMaker
    when :caption_maker_v8, :captionmaker_v8, :cap_v8
      CaptionMakerV8
    else
      raise InvalidCaptionFormatError
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

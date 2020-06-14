require 'hex_string'
require 'ruby-rtf'

def suppress_output
  original_stdout, original_stderr = $stdout.clone, $stderr.clone
  $stderr.reopen File.new('/dev/null', 'w')
  $stdout.reopen File.new('/dev/null', 'w')
  yield
ensure
  $stdout.reopen original_stdout
  $stderr.reopen original_stderr
end

class String
  def scan_with_captures(regexp)
    names = regexp.names
    scan(regexp).collect do |match|
      Hash[names.zip(match)]
    end
  end
end

module CaptionAmerica
  module CaptionMakerV8
    BLOCK_REGEX = /(?<block>00 ff fe ff 0b (?<time>.. 00 .. 00 3A 00 .. 00 .. 00 3A 00 .. 00 .. 00 3A 00 .. 00 .. 00) (?<attributes>.. .. .. .. .. .. .. .. .. .. .. .. ..) (?!00)(?!fe ff)(?<caption_data>[0-9A-F ]*?) 00 FF FE FF)/i

    IDENT = [
      0x2b, 0x27, 0x0f, 0x3c, 0x43, 0x61, 0x70, 0x4d, 0x61, 0x6b, 0x65, 0x72,
      0x20, 0x50, 0x6c, 0x75, 0x73, 0x3e, 0x04
    ]

    def self.read(filepath)
      captions = []

      # We're going to do this in a weird way, but this was the easiest way I
      # could come up with to find the specific data structures we're looking
      # for without having to figure out what the other data structures in
      # the file are.
      #
      # We're going to load the binary data, convert it to hex
      # and then pluck out the structures we need with regex.
      data = File.read(filepath).to_hex_string.downcase

      # Find the blocks we want to parse
      subtitle_records = data.scan_with_captures(BLOCK_REGEX)

      # Loop through each block and use our `HexStringByteBuffer` to read through it.
      subtitle_records.each_with_index do |match, idx|
        # Our regex isn't perfect and does pick up on a few metadata
        # fields earlier in the file. Their positioning in the file
        # depends on the length of data earlier in the file so its not
        # easy to determine a skip value. Instead, we'll just call these
        # out directly here.  It could probably be done in the regex above
        # but I'd rather keep the regex as readable as possible.
        if match["attributes"] == "01 00 00 00 00 00 00 00 00 00 00 00 00"
          next
        end

        if match["attributes"] == "00 00 00 00 00 00 00 00 00 00 00 00 FF"
          next
        end

        if match["attributes"] == "FF FE FF 00 FF FE FF 00 FF FE FF 00 FF"
          next
        end

        if match["caption_data"] == "FF FE FF 00 00 00 00"
          next
        end

        #puts "CHECKING: #{match["block"]}"
        captions << parse_subtitle_record(match["block"])
      end

      # TODO: Confirm whether or not we drop blank captions.
      captions = captions.reject { |c| c.text.length == 0 }

      return captions
    end

  private

    def self.parse_subtitle_record(hex_string)
      buffer = HexStringByteBuffer.new(hex_string)

      # Skip the four byte structure identifier 0x00fffeff
      buffer.skip(:uint8, count: 4)


      # Get the length of the text, this will always be 11
      len = buffer.uint8
      in_time = buffer.uint16(count: len).map(&:chr).join
      attributes = {
        position: buffer.float32,
        line: buffer.float32,
        justification: buffer.uint16,
        font_style: buffer.uint16
      }

      # Get the length of the caption block. If >= 255 the value will
      # be followed by a uint16 representing an extended length. This
      # extended text will also frequently be in rtf format.
      len = buffer.uint8
      if len == 0xff
        len = buffer.uint16
      end

      # The caption text, unliked the timecode, is stored as an array of bytes
      raw_text = buffer.uint8(count: len)
                           .map(&:chr)
                           .join

      caption_text = self.normalized_text(raw_text)

      # Assemble the cue data
      cue_data = {
        in_time: in_time,
        attributes: attributes,
        text: caption_text,
        raw_text: raw_text
      }

      return build_caption(cue_data)
    end

    def self.build_caption(cue_data)
      Caption.new.tap do |c|
        c.in_time = cue_data[:in_time]
        c.text = cue_data[:text]
        c.horizontal = cue_data[:position]
        c.vertical = cue_data[:line]
      end
    end

    def self.normalized_text(text)
      response = text.strip

      return response unless response.include? "{\\rtf1"

      doc = suppress_output { ::RubyRTF::Parser.new.parse(response) }


      # Reset the response and iterate
      response = ""
      doc.sections.each do |section|
        response = response + section[:text]
      end

      return response
    end

  end
end
require 'hex_string'

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

        captions << parse_subtitle_record(match["block"])
      end

      return captions
    end

  private

    def self.parse_subtitle_record(hex_string)
      buffer = HexStringByteBuffer.new(hex_string)
    end

  end
end
require 'memoist'
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
  class CaptionMaker < Adapter
    extend Memoist

    IDENT = [
      0x2b, 0x27, 0x0f, 0x3c, 0x43, 0x61, 0x70, 0x4d, 0x61, 0x6b, 0x65, 0x72,
      0x20, 0x50, 0x6c, 0x75, 0x73, 0x3e
    ]

    BLOCK_REGEX_8b  = /(?<block>00 0b (?<time>.. .. 3A .. .. 3A .. .. 3A .. ..) (?<attributes>.. .. .. .. .. .. .. .. .. .. .. .. ..) (?<caption_data>[0-9A-F ]*?) 00 00)/i
    BLOCK_REGEX_16b = /(?<block>00 ff fe ff 0b (?<time>.. 00 .. 00 3A 00 .. 00 .. 00 3A 00 .. 00 .. 00 3A 00 .. 00 .. 00) (?<attributes>.. .. .. .. .. .. .. .. .. .. .. .. ..) (?!00)(?!fe ff)(?<caption_data>[0-9A-F ]*?) 00 FF FE FF)/i

    attr_reader :data

    def initialize(filepath)
      super(filepath)

      @data = File.read(filepath).to_hex_string.downcase
    end

    def self.detect_byte_size(filepath)
      adapter = CaptionMaker.new(filepath)
      adapter.byte_size
    end

    def byte_size
      matches = @data.scan_with_captures(BLOCK_REGEX_16b)

      if (matches.length > 0)
        return 16
      end

      return 8
    end
    memoize :byte_size

    def read
      captions = []

      # We're going to do this in a weird way, but this was the easiest way I
      # could come up with to find the specific data structures we're looking
      # for without having to figure out what the other data structures in
      # the file are.
      #
      # We're going to load the binary data, convert it to hex
      # and then pluck out the structures we need with regex.
      buffer = HexStringByteBuffer.new(@data)
      identity = buffer.uint8(count: IDENT.length)

      if identity != IDENT
        raise CaptionAmerica::InvalidCaptionFileError
      end

      # Find the blocks we want to parse
      block_regex = self.byte_size(data) == 8 ? BLOCK_REGEX_8b : BLOCK_REGEX_16b
      subtitle_records = data.scan_with_captures(block_regex)

      # Loop through each block and use our `HexStringByteBuffer` to read through it.
      subtitle_records.each_with_index do |match, idx|
        # Our regex isn't perfect and does pick up on a few metadata
        # fields earlier in the file. Their positioning in the file
        # depends on the length of data earlier in the file so its not
        # easy to determine a skip value. Instead, we'll just call these
        # out directly here.  It could probably be done in the regex above
        # but I'd rather keep the regex as readable as possible.
        skip = false
        skippable_blocks.each do |skippable_block|
          if match["attributes"] == skippable_block
            skip = true
          end
        end
        next if skip

        parsed_caption = parse_subtitle_record(match["block"])

        captions << parsed_caption
      end

      calculate_out_times(captions)

      # After calculating out times, drop the blank captions.
      captions = captions.reject { |c| c.text.length == 0 }

      captions
    end

private

    def calculate_out_times(captions)
      captions.each_with_index do |caption, i|
        if i < captions.count-1
          # We need to handle the possibility that we have multiple captions
          # on s cree at once
          out_time = nil

          (i...captions.length).each do |n|
            if captions[n].in_time != caption.in_time
              out_time = captions[n].in_time if out_time.nil?
              break
            end
          end

          if out_time.nil?
            n = captions.length - 1
            caption.out_time = captions[n].in_time
          else
            caption.out_time = out_time
          end
        end
      end
    end

    def parse_subtitle_record(hex_string)
      buffer = HexStringByteBuffer.new(hex_string)

      # Skip the one byte structure identifier 0x000
      if byte_size == 8
        buffer.skip(:uint8, count: 1)
      else
        buffer.skip(:uint8, count: 4)
      end

      # Get the length of the text, this will always be 11
      len = buffer.uint8

      if byte_size == 8
        in_time = buffer.uint8(count: len).map(&:chr).join
      else
        in_time = buffer.uint16(count: len).map(&:chr).join
      end

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

      # The caption text, unlike the timecode, is stored as an array of bytes
      # Since we're mapping this, we'll force an array even on single reads.
      raw_text = buffer.uint8(count: len, array: true)
                       .map(&:chr)
                       .join

      # Normalize the music note
      raw_text = raw_text.unpack('C*').pack('U*')

      text = styled_text(raw_text)

      text.gsub!("§", "♪")

      plain_text = plain_text(text)

      # Assemble the cue data
      cue_data = {
        in_time: in_time,
        attributes: attributes,
        text: text,
        plain_text: plain_text,
        raw_text: raw_text
      }

      return build_caption(cue_data)
    end

    def build_caption(cue_data)
      Caption.new.tap do |c|
        c.in_time = cue_data[:in_time]
        c.text = cue_data[:text]
        c.horizontal = normalize_horizontal_position(cue_data[:attributes][:position])
        c.vertical = normalize_vertical_position(cue_data[:attributes][:line])
      end
    end

    def normalize_horizontal_position(position)
      case position
      when -1
        Caption::Position::CENTER
      when 0
        Caption::Position::LEFT
      when -2
        Caption::Position::RIGHT
      else
        position
      end
    end

    def normalize_vertical_position(position)
      case position
      when -1
        Caption::Position::CENTER
      when 0
        Caption::Position::TOP
      when -2
        Caption::Position::BOTTOM
      else
        position
      end
    end

    def plain_text(text)
      html = styled_text(text)

      text
    end

    # TODO: FIXME: I think we're just going to go with HTML as the interchange format.
    # It covers all the styling we could need and is easily parsable, there's no reason
    # to invent a style agnostic format.
    def styled_text(text)
      output = ""

      return text unless text.include? "{\\rtf1"

      doc = suppress_output { ::RubyRTF::Parser.new.parse(text) }

      doc.sections.each do |section|
        mods = section[:modifiers]

        prefix = ''
        suffix = ''

        if mods[:paragraph] && section[:text].empty?
          output << "\n"
        end

        next if section[:text].empty?

        if mods[:paragraph]
          prefix = "#{prefix}<p>"
          suffix = "</p>#{suffix}"
        end

        if mods[:italic]
          prefix = "#{prefix}<i>"
          suffix = "</i>#{suffix}"
        end

        if mods[:bold]
          prefix = "#{prefix}<b>"
          suffix = "</b>#{suffix}"
        end

        output << "#{prefix}#{section[:text]}#{suffix}"
      end

      output.strip
    end
    memoize :styled_text

    # Our block finder regex isn't perfect, but we can filter out the false
    # postives pretty easily
    def skippable_blocks
      case byte_size
      when 8
        ["00 00 00 00 00 00 00 00 00 00 00 00 0b"]
      when 16
        [
          "01 00 00 00 00 00 00 00 00 00 00 00 00",
          "00 00 00 00 00 00 00 00 00 00 00 00 FF",
          "FF FE FF 00 FF FE FF 00 FF FE FF 00 FF",
          "FF FE FF 00 00 00 00"
        ]
      else
        []
      end
    end
  end
end
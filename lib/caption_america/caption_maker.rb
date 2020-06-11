module CaptionAmerica
  module CaptionMaker
    IDENT = [
      0x2b, 0x27, 0x0f, 0x3c, 0x43, 0x61, 0x70, 0x4d, 0x61, 0x6b, 0x65, 0x72,
      0x20, 0x50, 0x6c, 0x75, 0x73, 0x3e, 0x04
    ]

    class FileFormat < ::BinData::Record
      endian :little

      class ByteArray < ::BinData::Array
        endian :little

        uint8 initial_value: 0x00
      end

      class Header < ::BinData::Record
        endian :little

        byte_array :ident, initial_length: 19
      end

      header :header
    end

    def self.read(filepath)
      captions = []

      data = File.read(filepath)

      cap = FileFormat.read(data)

      raise CaptionAmerica::InvalidCaptionFileError unless cap.header.ident == IDENT

      return captions
    end
  end
end
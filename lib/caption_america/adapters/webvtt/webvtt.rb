module CaptionAmerica
  module WebVTT
    def self.generate(captions)
      chunks = []

      captions.each do |caption|
        chunks << generate_chunk(caption)
      end

      lines = ['WEBVTT']
      lines << "X-TIMESTAMP-MAP=LOCAL:00:00:00.000,MPEGTS:900000"
      lines << ""
      lines += chunks

      lines.join("\n")
    end

    def self.generate_chunk(caption)
      vtt_chunk = <<~VTT
      #{caption.in_time} --> #{caption.out_time} #{caption_block_header(caption)}
      #{caption.text}

      VTT

      vtt_chunk
    end

    def self.read(filepath)
      data = File.read(filepath)

      self.fromString(data)
    end

    def self.fromString(vtt_string)
      captions = []

      lines = vtt_string.split("\n")

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

      captions.map { |c| c.text.strip! }

      captions
    end

  private

    def self.caption_block_header(caption)
      header = []



      header.join(' ')
    end

    def self.is_caption_block_header?(line)
      return false unless line.include? "-->"

      tokens = line.split(/\s+/)

      # Must at least have an in and out point
      return false unless tokens.count >= 3

      in_time = tokens[0]
      out_time = tokens[2]

      true
    end

    def self.get_in_and_out_time(line)
      tokens = line.split(/\s+/)

      in_time = tokens[0]
      out_time = tokens[2]

      [in_time, out_time]
    end
  end
end
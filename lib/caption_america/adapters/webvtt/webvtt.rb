require 'rmagick'
include Magick

module CaptionAmerica
  class WebVTT < Adapter
    MARGIN      = 10
    WIDTH       = 1920
    HEIGHT      = 1080
    FONT_SIZE   = 56
    KERNING     = 5
    BOX_PADDING = 10

    def self.generate(captions, margin: MARGIN)
      chunks = []

      captions.each do |caption|
        chunks << WebVTT::generate_chunk(caption, margin: margin)
      end

      lines = ['WEBVTT']
      lines << "X-TIMESTAMP-MAP=LOCAL:00:00:00.000,MPEGTS:900000"
      lines << ""
      lines += chunks

      lines.join("\n")
    end

    def self.generate_chunk(caption, margin: MARGIN)
      vtt_chunk = <<~VTT
      #{vtt_time(caption.in_time)} --> #{vtt_time(caption.out_time)} #{position_headers(caption, margin: margin)}
      #{caption.text}
      VTT

      vtt_chunk
    end

    def self.vtt_time(timecode)
      fps = 29.97

      return "00:00:00.000" if timecode.nil?
      return timecode if timecode.include? "."

      hours, minutes, seconds, frames  = timecode.split(":")

      fractional_seconds = ((1.0/fps) * 1000 * frames.to_i).round.to_s.rjust(3, "0")

      "#{hours}:#{minutes}:#{seconds}.#{fractional_seconds}"
    end

    def read
      file = File.open(self.filepath, "r:bom|utf-8")
      data = file.read
      file.close

      WebVTT::fromString(data)
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

    def self.position_headers(caption, margin: MARGIN)
      attributes = []

      num_lines = caption.plain_text.split("\n").count
      box_metrics = self.get_metrics_if_needed(caption)

      #
      # VERTICAL
      #
      if caption.vertical == Caption::Position::TOP
        attributes << "line:#{margin}%"
      elsif caption.vertical == Caption::Position::BOTTOM
        # FIXME: This is a hacky magic number based on observation.
        # We were attempting to measure string metrics with rmagick
        # but that wasn't working out. Come back to this.
        line_height = 5.8
        pos = 100 - margin - (num_lines * line_height)

        # We're adding 15px of padding on the view, let's account for it here
        # FIXME: This probably isn't needed any longer, run some tests and see
        pos = pos + 2.08

        attributes << "line:#{pos.round}%"
      elsif caption.vertical == Caption::Position::CENTER
        pos = 50 - (box_metrics[:box_height].to_f / 2)
        attributes << "line:#{pos}%"
      else
        pos = (caption.vertical * 100).round
        attributes << "line:#{pos}%"
      end

      #
      # HORIZONTAL
      #
      if caption.horizontal == Caption::Position::LEFT
        attributes << "align:start"
        attributes << "position:#{margin}%"
      elsif caption.horizontal == Caption::Position::RIGHT
        pos = 100 - margin - box_metrics[:box_width]

        attributes << "align:start"
        attributes << "position:#{pos}%"
      elsif caption.horizontal == Caption::Position::CENTER
        attributes << "align:middle"
        attributes << "position:50%"
      end

      return attributes.join(' ')
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


    def self.get_metrics_if_needed(caption)
      measure = true

      # We don't need to measure top or bottom placements
      measure = false if caption.vertical == Caption::Position::TOP
      measure = false if caption.vertical == Caption::Position::BOTTOM

      # Left and center placements do not need to be measures
      measure = true if caption.horizontal != Caption::Position::LEFT && caption.horizontal != Caption::Position::CENTER

      return if caption.blank?
      return if measure == false

      canvas = ImageList.new
      canvas.new_image(WIDTH, HEIGHT, HatchFill.new('white', 'gray90'))

      label = Draw.new

      # FIXME: Check the Arial font on the linxu workers
      if caption.italic?
        label.font = "/Library/Fonts/Arial Bold Italic.ttf"
      else
        label.font = "/Library/Fonts/Arial Bold.ttf"
      end

      label.font_style = Magick::NormalStyle

      #
      # Apply font styles if needed
      #
      label.font_style = Magick::ItalicStyle if caption.italic?

      label.pointsize = FONT_SIZE
      label.font_weight = Magick::BoldWeight
      label.gravity = Magick::NorthWestGravity
      label.stroke_width = 1
      label.stroke = 'red'
      label.kerning = KERNING
      label.fill = '#ff0000'

      # Measure the text based on the font settings defined above
      #
      metrics = label.get_multiline_type_metrics(caption.plain_text)

      width = metrics.width
      height = metrics.height

      box_width = ((((width.to_f + BOX_PADDING + BOX_PADDING) / WIDTH.to_f)) * 100).round # adjust for padding
      box_height = ((((height.to_f + BOX_PADDING + BOX_PADDING) / HEIGHT.to_f)) * 100).round # adjust for padding

      return {
        width: width,
        height: height,
        box_width: box_width,
        box_height: box_height
      }
    end

  end
end
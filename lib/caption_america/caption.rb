module CaptionAmerica
  class Caption
    # Cue Timing
    attr_accessor :start_time, :end_time

    # Payload
    attr_accessor :text

    # Positioning
    attr_accessor :horizontal, :vertical
    attr_accessor :justification

    # Styling
    attr_accessor :foreground, :background
    attr_accessor :bold, :italic, :underline
    attr_accessor :font, :font_size

    def in
      start_time
    end

    def out
      end_time
    end
  end
end
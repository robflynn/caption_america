module CaptionAmerica
  class Caption
    # Cue Timing
    attr_accessor :in_time, :out_time

    # Payload
    attr_accessor :text

    # Positioning
    attr_accessor :horizontal, :vertical
    attr_accessor :justification

    # Styling
    attr_accessor :foreground, :background
    attr_accessor :bold, :italic, :underline
    attr_accessor :font, :font_size

    def initialize
      @text = ""
    end
  end
end
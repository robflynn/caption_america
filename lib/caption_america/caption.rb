module CaptionAmerica
  class Caption
    # Cue Timing
    attr_accessor :in_time, :out_time

    # Payload
    attr_accessor :text
    attr_accessor :raw_text

    # Positioning
    attr_accessor :horizontal, :vertical
    attr_accessor :justification

    def initialize
      @text = ""
      @raw_text = ""
    end
  end
end
require 'nokogiri'
require 'memoist'

module CaptionAmerica
  class Caption
    extend Memoist

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

    class StyledSection
      module Style
        NORMAL    = 0b00000000
        BOLD      = 0b00000001
        ITALIC    = 0b00000010
        UNDERLINE = 0b00000100
      end
    end

    def initialize
      @text = ""
    end

    def plain_text
      doc = Nokogiri::HTML(self.text)
      doc.xpath("//text()").remove.to_s.strip
    end
    memoize :plain_text
  end
end
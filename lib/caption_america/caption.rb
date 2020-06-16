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

    module Position
      TOP    = "top"
      BOTTOM = "bottom"
      CENTER = "center"
      LEFT   = "left"
      RIGHT  = "right"
    end

    def initialize
      @text = ""
      @horizontal = Position::CENTER
      @vertical = Position::BOTTOM
    end

    def blank?
      plain_text.length == 0
    end

    def italic?
      text.downcase.include? "<i>"
    end

    def bold?
      text.downcase.include? "<b>"
    end

    def plain_text
      doc = Nokogiri::HTML(self.text)
      doc.xpath("//text()").remove.to_s.strip
    end
    memoize :plain_text
  end
end
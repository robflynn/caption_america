require 'memoist'

module CaptionAmerica
  class SRT
    extend Memoist

    def self.generate(captions)
      chunks = []

      captions.each do |caption|
        block = `${caption}.in_time --> ${caption.out_time}\n`
        block += `${caption.text}\n`

        chunks << block
      end

      chunks.join("\n")
    end
    memoize :generate

    def read
      []
    end
  end
end
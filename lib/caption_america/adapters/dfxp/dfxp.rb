module CaptionAmerica
  class DFXP < Adapter
    def read
      data = File.read(self.filepath)

      DFXP::fromString(data)
    end

    def self.fromString(data)
      captions = []

      doc = Nokogiri::XML(data)

      items = doc.xpath("//tt:p", "tt": "http://www.w3.org/ns/ttml")
      items.each do |item|
        captions << build_caption(item)
      end

      captions
    end

  private

    def self.build_caption(item)
      Caption.new.tap do |c|
        c.in_time = item["begin"]
        c.out_time = item["end"]
        c.vertical = Caption::Position::BOTTOM
        c.horizontal = Caption::Position::CENTER

        caption_html = item.children.map {|c| c.to_html }.join
        html = Nokogiri::HTML.fragment(caption_html)
        html.css("br").each { |br| br.replace("\n") }
        c.text = html.to_html
      end
    end
  end
end
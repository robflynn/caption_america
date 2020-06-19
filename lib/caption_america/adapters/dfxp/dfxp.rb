module CaptionAmerica
  class DFXP < Adapter
    def read
      data = File.read(self.filepath)

      DFXP::fromString(data)
    end

    def self.fromString(data)
      captions = []
      collections = []

      doc = Nokogiri::XML(data)

      items = doc.xpath("//tt:p", "tt": "http://www.w3.org/ns/ttml")
      items.each do |item|
        collection = {
          caption: build_caption(item)
        }

        collections << collection
      end

      collections.map { |c| c[:caption] }
    end

  private

    def self.build_caption(item)
      Caption.new.tap do |c|
        c.in_time = item["begin"]
        c.out_time = item["end"]
        c.vertical = Caption::Position::BOTTOM
        c.horizontal = Caption::Position::CENTER

        c.text = collect_html(item)
      end
    end

    def self.collect_html(element)
      caption_html = element.children.map {|c| c.to_html }.join
      html = Nokogiri::HTML.fragment(caption_html)
      html.css("br").each { |br| br.replace("\n") }

      html.to_html
    end
  end
end
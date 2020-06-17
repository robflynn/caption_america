require_relative './spec_helper'

describe 'CaptionAmerica' do
  it 'should throw invalid caption format error' do
    expect { CaptionAmerica.read("test.caption", :invalid_format) }.must_raise CaptionAmerica::UnknownCaptionFormatError
  end

  describe 'Caption' do
    it "temporary test" do
      captions = CaptionAmerica.read(fixture("8855_Its_A_Dogs_Day.cap"), :cap)

      captions.each do |c|
        c.text = "<b>#{c.text}</b>"
      end

      vtt = CaptionAmerica::WebVTT.generate(captions)

      File.write("/Users/robflynn/womble.vtt", vtt)
    end

    it 'should convert html to plain_text' do
      caption = CaptionAmerica::Caption.new
      caption.text = "<b>Hello, <i>William</i>.</b>"

      assert_equal("Hello, William.", caption.plain_text)

      caption = CaptionAmerica::Caption.new
      caption.text = "Hello! I'm Rob-ot!"

      assert_equal("Hello! I'm Rob-ot!", caption.plain_text)
    end

    it 'should report on the styles it contains' do
      caption = CaptionAmerica::Caption.new
      caption.text = "<b>Hello, William.</b>"

      assert_equal(true, caption.bold?)
      assert_equal(false, caption.italic?)

      caption = CaptionAmerica::Caption.new
      caption.text = "<i>Hello, <b>William</b>.</i>"

      assert_equal(true, caption.bold?)
      assert_equal(true, caption.italic?)
    end

    it 'should be able to detect blank captions' do
      caption = CaptionAmerica::Caption.new
      caption.text = "<b>Hello, <i>William</i>.</b>"
      assert_equal(false, caption.blank?)

      caption = CaptionAmerica::Caption.new
      caption.text = ""
      assert_equal(true, caption.blank?)

      caption = CaptionAmerica::Caption.new
      caption.text = "<b><i></i></b>"
      assert_equal(true, caption.blank?)
    end

    it 'should be able to understand simultaneously captions' do
      captions = CaptionAmerica.read(fixture("8855_Its_A_Dogs_Day.cap"), :cap)

      caption1 = captions[14]
      caption2 = captions[15]

      assert_equal("00:01:04:00", caption1.in_time)
      assert_equal("00:01:04:00", caption2.in_time)

      assert_equal("00:01:05:22", caption1.out_time)
      assert_equal("00:01:05:22", caption2.out_time)
    end
  end
end
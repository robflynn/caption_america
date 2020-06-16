require_relative './spec_helper'

describe 'CaptionAmerica' do
  it 'should throw invalid caption format error' do
    expect { CaptionAmerica.read("test.caption", :invalid_format) }.must_raise CaptionAmerica::UnknownCaptionFormatError
  end

  describe 'Caption' do
    it "temporary test" do
      captions = CaptionAmerica.read(fixture("8855_Its_A_Dogs_Day.cap"), :cap)

      vtt = CaptionAmerica::WebVTT.generate(captions)

      puts vtt
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
  end
end
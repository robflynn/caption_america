require_relative './spec_helper'

describe 'CaptionAmerica' do
  it 'should throw invalid caption format error' do
    expect { CaptionAmerica.read("test.caption", :invalid_format) }.must_raise CaptionAmerica::UnknownCaptionFormatError
  end

  describe 'Caption' do
    it 'should convert html to plain_text' do
      caption = CaptionAmerica::Caption.new
      caption.text = "<b>Hello, <i>William</i>.</b>"

      assert_equal("Hello, William.", caption.plain_text)
    end
  end
end
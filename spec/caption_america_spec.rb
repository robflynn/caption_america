require_relative './spec_helper'

describe 'CaptionAmerica' do
  it 'should throw invalid caption format error' do
    expect { CaptionAmerica.read("test.caption", :invalid_format) }.must_raise CaptionAmerica::UnknownCaptionFormatError
  end

  describe 'captions' do
    it 'should be able to read a valid caption file' do
      captions = CaptionAmerica.read(fixture('webvtt.vtt'), :vtt)

      assert_equal(2, captions.count)

      assert_equal("test caption", captions[0].text)
    end
  end
end
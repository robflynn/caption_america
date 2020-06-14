require_relative './spec_helper'

describe 'WebVTT Adapter' do
  it 'should be able to read a valid WebVTT file' do
    captions = CaptionAmerica::WebVTT.read(fixture("webvtt.vtt"))

    assert_equal(2, captions.length)

    caption = captions[0]
    assert_equal("test caption", caption.text)
    assert_equal("00:00:01.000", caption.in_time)
    assert_equal("00:00:05.000", caption.out_time)
  end

  it 'should throw an InvalidCaptionFileError when given an invalid file' do
    expect { CaptionAmerica::WebVTT.read(fixture("captionmakerv8.1.1.cap")).must_raise CaptionAmerica::InvalidCaptionFileError }
  end
end
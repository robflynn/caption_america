require_relative './spec_helper'

describe 'WebVTT Adapter' do
  it 'should be able to read a valid WebVTT file' do
    adapter = CaptionAmerica::WebVTT.new(fixture("webvtt.vtt"))
    captions = adapter.read

    assert_equal(2, captions.length)

    caption = captions[0]
    assert_equal("test caption", caption.text)
    assert_equal("00:00:01.000", caption.in_time)
    assert_equal("00:00:05.000", caption.out_time)
  end

  it 'should throw an InvalidCaptionFileError when given an invalid file' do
    expect { CaptionAmerica::WebVTT.read(fixture("captionmakerv8.1.1.cap")).must_raise CaptionAmerica::InvalidCaptionFileError }
  end

  it 'should be able to generate a valid webvtt file' do
    captions = []

    captions << CaptionAmerica::Caption.new.tap do |c|
      c.in_time = "00:00:00:00"
      c.out_time = "00:00:00:05"
      c.text = "test caption"
    end

    captions << CaptionAmerica::Caption.new.tap do |c|
      c.in_time = "00:00:00:05"
      c.out_time = "00:00:00:10"
      c.text = "test caption 2"
    end

    result = CaptionAmerica::WebVTT.generate(captions)
    File.write("/Users/robflynn/foozle.vtt", result)

    parsed_captions = CaptionAmerica::WebVTT.fromString(result)
    assert_equal("test caption 2", parsed_captions[1].text)
    assert_equal("00:00:00:10", parsed_captions[1].out_time)
    assert_equal("00:00:00:05", parsed_captions[1].in_time)


  end
end
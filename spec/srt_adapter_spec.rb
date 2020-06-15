require_relative './spec_helper'

describe 'SRTAdapter' do
  it 'should be able to read a valid srt file' do
    adapter = CaptionAmerica::SRT.new(fixture("srt.srt"))
    captions = adapter.read

    assert_equal(2, captions.length)

    caption = captions[0]
    assert_equal("test caption", caption.text)
    assert_equal("00:00:01.000", caption.in_time)
    assert_equal("00:00:05.000", caption.out_time)
  end

  it 'should throw an InvalidCaptionFileError when given an invalid file' do
    assert_raises CaptionAmerica::InvalidCaptionFileError do
      adapter = CaptionAmerica::SRT.new(fixture('webvtt.vtt'))
      adapter.read
    end
  end

  it 'should be able to generate a valid srt file' do
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

    result = CaptionAmerica::SRT.generate(captions)
    # FIXME: I'm being lazy, make this not-me agnostic
    File.write("/Users/robflynn/foozle.srt", result)

    parsed_captions = CaptionAmerica::SRT.new("/Users/robflynn/foozle.srt")

    assert_equal("test caption 2", parsed_captions[1].text)
    assert_equal("00:00:00:10", parsed_captions[1].out_time)
    assert_equal("00:00:00:05", parsed_captions[1].in_time)
  end
end
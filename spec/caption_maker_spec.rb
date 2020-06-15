require_relative './spec_helper'

describe 'CaptionMaker' do
  it 'should be able to read a captionmaker file' do
    captions = CaptionAmerica.read(fixture('captionmaker.cap'), :caption_maker)

    assert_equal(3, captions.count)

    caption = captions[0]

    assert_equal("This is a caption", caption.text)
    assert_equal("00:00:00:15", caption.in_time)
    assert_equal("00:00:05:00", caption.out_time)
  end

  it 'Should throw an invalid file error when given an invalid file' do
    assert_raises CaptionAmerica::InvalidCaptionFileError do
      CaptionAmerica::CaptionMaker.read(fixture('webvtt.vtt'))
    end
  end

  it "Should be able to detect which integer size to use" do
    data = File.read(fixture("captionmaker.cap")).to_hex_string
    integer_size = CaptionAmerica::CaptionMaker.byte_size(data)
    assert_equal(8, integer_size)

    data = File.read(fixture("captionmakerv8.1.1.cap")).to_hex_string
    integer_size = CaptionAmerica::CaptionMaker.byte_size(data)

    assert_equal(16, integer_size)
  end
end
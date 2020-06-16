require_relative './spec_helper'

describe 'CaptionMaker' do
  it 'should be able to read an 8 bit integer captionmaker file' do
    captions = CaptionAmerica.read(fixture('captionmaker.cap'), :caption_maker)

    assert_equal(3, captions.count)

    caption = captions[0]

    assert_equal("This is a caption", caption.text)
    assert_equal("00:00:00:15", caption.in_time)
    assert_equal("00:00:05:00", caption.out_time)
  end

  it 'should be able to read an 16 bit integer captionmaker file' do
    captions = CaptionAmerica.read(fixture('captionmakerv8.1.1.cap'), :caption_maker)

    caption = captions[3]

    assert_equal("Hi, I'm Luke,\nand this is Teen Kids News.", caption.plain_text)
    assert_equal("<b>Hi, I'm Luke,</b>\n<b>and this is </b><i><b>Teen Kids News.</b></i>", caption.text)
    assert_equal("00:00:14:17", caption.in_time)
    assert_equal("00:00:18:00", caption.out_time)

    assert_equal(395, captions.count)
  end

  it 'Should throw an invalid file error when given an invalid file' do
    assert_raises CaptionAmerica::InvalidCaptionFileError do
      adapter = CaptionAmerica::CaptionMaker.new(fixture('webvtt.vtt'))
      adapter.read
    end
  end

  it "Should be able to detect which integer size to use" do
    integer_size = CaptionAmerica::CaptionMaker::detect_byte_size(fixture("captionmaker.cap"))
    assert_equal(8, integer_size)

    integer_size = CaptionAmerica::CaptionMaker::detect_byte_size(fixture("captionmakerv8.1.1.cap"))
    assert_equal(16, integer_size)
  end

  it "Should be able to parse a caption with a length of 1" do
    captions = CaptionAmerica::read(fixture("one_character_caption.cap"), :caption_maker)

    assert_equal("!", captions[0].plain_text)
  end
end
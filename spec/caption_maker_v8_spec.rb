require_relative './spec_helper'

describe 'CaptionMaker v8' do
  it 'should be able to read a captionmaker v8 file' do
    captions = CaptionAmerica.read(fixture('captionmakerv8.1.1.cap'), :caption_maker_v8)

    caption = captions[3]

    assert_equal("Hi, I'm Luke,and this is Teen Kids News.", caption.text)
    assert_equal("00:00:14:17", caption.in_time)
    assert_equal("00:00:18:00", caption.out_time)

    assert_equal(395, captions.count)
  end

  it 'Should throw an invalid file error when given an invalid file' do
    expect { CaptionAmerica.read(fixture('webvtt.vtt'), :caption_maker_v8).must_raise CaptionAmerica::InvalidCaptionFileError }
  end
end
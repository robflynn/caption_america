require_relative './spec_helper'

describe 'CaptionAmerica' do
  it 'should throw invalid caption format error' do
    expect { CaptionAmerica.read("test.caption", :invalid_format) }.must_raise CaptionAmerica::InvalidCaptionFormatError
  end

  describe 'CaptionMaker' do
    it 'should be able to read a caption maker file' do
      captions = CaptionAmerica.read(fixture('captionmaker.cap'), :caption_maker)

      assert_equal(3, captions.count)
    end

    it 'should be throw an invalid format error when given an invalid file' do
      expect { CaptionAmerica.read(fixture('webvtt.vtt', :caption_maker)).must_raise CaptionAmerica::InvalidCaptionFileError }
    end
  end

  describe 'captions' do
    it 'should be able to read a valid caption file' do
      captions = CaptionAmerica.read(fixture('webvtt.vtt'), :vtt)

      assert_equal(2, captions.count)

      assert_equal("test caption", captions[0].text)
    end
  end

  describe 'CueTime' do
    it 'should convert a timecode to frames' do
      frames = CaptionAmerica::CueTime.to_frames("00:00:00:17")

      assert_equal(17, frames)
    end

    it 'should convert a timecode to frames using a custom fps' do
      frames = CaptionAmerica::CueTime.to_frames("00:00:01:00", fps: 10)

      assert_equal(10, frames)
    end

    it 'should convert a timecode to frames using non-drop' do
      frames = CaptionAmerica::CueTime.to_frames("00:23:13:00", drop_frame: true)

      assert_equal(41750, frames)
    end

    it 'should convert timecodes in the format of HH:MM:SS.MMM to milliseconds' do
      ms = CaptionAmerica::CueTime.to_milliseconds("00:00:01.250")
      assert_equal(1250, ms)
    end

    it 'should convert timecodes in the format of HH:MM:SS to milliseconds' do
      ms = CaptionAmerica::CueTime.to_milliseconds("00:03:12")
      assert_equal(192000, ms)
    end

    it 'should convert timecodes in the format of HH:MM:SS:FF to milliseconds' do
      ms = CaptionAmerica::CueTime.to_milliseconds("00:00:00:17")
      assert_equal(567, ms)
    end

    describe 'parsing invalid timecode' do
      it 'should raise InvalidTimestampError' do
        expect { CaptionAmerica::CueTime.to_milliseconds("bananas") }.must_raise CaptionAmerica::InvalidTimestampError
      end
    end
  end
end
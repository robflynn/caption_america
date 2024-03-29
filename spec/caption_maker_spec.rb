require_relative './spec_helper'

describe 'CaptionMaker' do
  # NOTE: Disabled these tests, we no longer work with this format.
  # it 'should be able to read an 8 bit integer captionmaker file' do
  #   captions = CaptionAmerica.read(fixture('captionmaker.cap'))

  #   assert_equal(3, captions.count)

  #   caption = captions[0]

  #   assert_equal("This is a caption", caption.text)
  #   assert_equal("00:00:00:15", caption.in_time)
  #   assert_equal("00:00:05:00", caption.out_time)
  # end

  # it 'should be able to read an 16 bit integer captionmaker file' do
  #   captions = CaptionAmerica.read(fixture('captionmakerv8.1.1.cap'))

  #   caption = captions[3]

  #   assert_equal("Hi, I'm Luke,\nand this is Teen Kids News.", caption.plain_text)
  #   assert_equal("<b>Hi, I'm Luke,</b>\n<b>and this is </b><i><b>Teen Kids News.</b></i>", caption.text)
  #   assert_equal("00:00:14:17", caption.in_time)
  #   assert_equal("00:00:18:00", caption.out_time)

  #   assert_equal(395, captions.count)
  # end

  # it 'Should throw an invalid file error when given an invalid file' do
  #   assert_raises CaptionAmerica::InvalidCaptionFileError do
  #     adapter = CaptionAmerica::CaptionMaker.new(fixture('webvtt.vtt'))
  #     adapter.read
  #   end
  # end

  # it "Should be able to detect which integer size to use" do
  #   integer_size = CaptionAmerica::CaptionMaker::detect_byte_size(fixture("captionmaker.cap"))
  #   assert_equal(8, integer_size)

  #   integer_size = CaptionAmerica::CaptionMaker::detect_byte_size(fixture("captionmakerv8.1.1.cap"))
  #   assert_equal(16, integer_size)
  # end

  # it "Should be able to parse a caption with a length of 1" do
  #   captions = CaptionAmerica::read(fixture("one_character_caption.cap"))

  #   assert_equal("!", captions[0].plain_text)
  # end

  # # Recently discovered edge case, only run across it once but could occur more often
  # it "Should handle the final caption and clearing caption having the same timestamp" do
  #   captions = CaptionAmerica.read(fixture("9729_The_Three_Little_Pigs.cap"), :cap)
  #   final_caption = captions.last

  #   assert_operator "00:00:00:00", :!=, final_caption.out_time

  #   in_frame_time = CaptionAmerica::CueTime.to_frames(final_caption.in_time)
  #   out_frame_time = CaptionAmerica::CueTime.to_frames(final_caption.out_time)

  #   assert_operator in_frame_time, :<=, out_frame_time
  # end

  # it "Should be able to parse music notes in rtf text" do
  #   captions = CaptionAmerica.read(fixture("13062_Zoobabu_Swan_Spanish.cap"))

  #   caption = captions[2]

  #   assert_equal("♪", caption.plain_text)
  # end

  # it 'Does not erroneously drop some captions' do
  #   c1 = CaptionAmerica.read(fixture("microworlds.vtt"))
  #   c2 = CaptionAmerica.read(fixture("microworlds.cap"))

  #   assert_equal(c1.length, c2.length)
  # end

end
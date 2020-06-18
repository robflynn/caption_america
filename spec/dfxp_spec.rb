describe 'DFXP' do
  it 'should be able to parse a DFXP file' do
    captions = CaptionAmerica.read(fixture("dfxp.dfxp"))

    assert_equal(2, captions.length)

    caption = captions[0]

    assert_equal("test caption", caption.plain_text)
  end
end
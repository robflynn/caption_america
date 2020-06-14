require_relative './spec_helper'

describe 'HexStringByteBuffer' do
  it 'should be able to skip data' do
    hex_string = "0A 0B 0C 0D"
    buffer = HexStringByteBuffer.new(hex_string)
    initial_offset = buffer.offset
    buffer.skip(:uint8, count: 2)

    assert_equal(initial_offset + 2, buffer.offset)
  end

  it 'should be able to read a uint8' do
    hex_string = "0A 0B 0C 0D"
    buffer = HexStringByteBuffer.new(hex_string)
    byte = buffer.uint8

    assert_equal(0x0a, byte)
  end

  it 'should be able to read multiple bytes' do
    hex_string = "0A 0B 0C 0D"
    buffer = HexStringByteBuffer.new(hex_string)
    byte = buffer.uint8 count: 2

    assert_equal([0x0a, 0x0b], byte)
  end

  it 'should be able to read a little endian uint16' do
    hex_string = "0A 0B 0C 0D"
    buffer = HexStringByteBuffer.new(hex_string)
    word = buffer.uint16

    assert_equal(0x0b0a, word)
  end

  it 'should be able to read a little endian float32' do
    hex_string = "00 00 c0 bf"
    buffer = HexStringByteBuffer.new(hex_string)
    float = buffer.float32

    assert_equal(-1.5, float)
  end
end

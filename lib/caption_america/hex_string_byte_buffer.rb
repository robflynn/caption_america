class HexStringByteBuffer
  attr_accessor :offset

  def initialize(data)
    @data = data.split(' ')
    @offset = 0
    @primitives = {}

    initialize_primitives
  end

  def read(bytes: 1)
    final_offset = @offset + bytes
    chunk = @data[@offset...final_offset]

    @offset = @offset + bytes

    chunk
  end

  # This is mostly just for efficiency, we can
  # just move our offset pointer and avoid creating
  # needless objects.
  def skip(type, count: 1)
    skip_size = primitive_size(type) * count

        @offset = @offset + skip_size
      end

  def add_primitive(type, bytes:, &block)
    @primitives[type] = {
      bytes: bytes,
      proc: block
    }
  end

  def method_missing(m, **args, &block)
    primitive = @primitives[m.to_sym]

    raise NoMethodError.new("Method `#{m}` doesn't exist.") if primitive.nil?

    args[:count] ||= 1

    handle_primitive(primitive, args)
  end

  def handle_primitive(primitive, **args)
    count = args[:count] || 1
    array = args[:array] || false
    chunk = self.read(bytes: primitive[:bytes] * count)

    response = primitive[:proc].call(chunk, count: count)

    # If only reading a single item, return the item, otherwise
    # return an array
    if response.is_a? Array
      return response.length == 1 && !array ? response[0] : response.flatten
    end

    response
  end

private

  def primitive_size(prim)
    @primitives[prim][:bytes]
  end

  def initialize_primitives
    add_primitive(:uint8, bytes: 1) do |chunk|
      chunk.join(' ').to_byte_string.unpack('C*')
    end

    add_primitive(:uint16, bytes: 2) do |chunk|
      chunk.join(' ').to_byte_string.unpack('S*')
    end

    add_primitive(:float32, bytes: 4) do |chunk|
      chunk.join(' ').to_byte_string.unpack('e')
    end
  end
end
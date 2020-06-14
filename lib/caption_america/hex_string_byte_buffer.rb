class HexStringByteBuffer
  def initialize(data)
    @data = data.split(' ')
    @offset = 0
    @primitives = {}

    initialize_primitives
  end

  def read(bytes: 1)
    chunk = @data.shift(bytes)
    @offset = @offset + bytes
    chunk
  end

  def add_primitive(type, bytes:, &block)
    @primitives[type] = {
      bytes: bytes,
      proc: block
    }
  end

  def method_missing(m, *args, &block)
    primitive = @primitives[m.to_sym]

    raise NoMethodError.new("Method `#{m}` doesn't exist.") if primitive.nil?

    handle_primitive(primitive, *args)
  end

  def handle_primitive(primitive, **args)
    count = args[:count] || 1
    chunk = self.read(bytes: primitive[:bytes] * count)

    response = []
    count.times do
      response << primitive[:proc].call(chunk, count: count)
    end

    if response.length == 0
      raise "Yo something went wrong"
    end

    # If only reading a single item, return the item, otherwise
    # return an array
    response.length == 1 ? response[0] : response
  end

private

  def initialize_primitives
    add_primitive(:uint8, bytes: 1) do |chunk|
      chunk.join(' ').to_byte_string.unpack('C')[0]
    end
  end
end
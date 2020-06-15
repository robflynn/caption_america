module CaptionAmerica
  class Adapter
    attr_reader :filepath

    def initialize(filepath)
      @filepath = filepath
    end

    def read
      #raise NoMethodError.new("Method `#{read}` doesn't exist.")
    end
  end
end
module Ban
  class IrEvent < Event
    CMD = 0x36

    attr_reader :code

    def self.parse(data)
      new(Ban.decode7bit(data).to_i)
    end

    def initialize(code)
      @code = code
    end

    def name
      'ir-received'
    end

    def hex
      code.to_s(16)
    end

    def to_hash
      { 'code' => @code, 'hex' => hex }
    end

    def to_s
      "#{code} (0x#{hex})"
    end
  end
end

module Ban
  class RcEvent < Event
    CMD = 0x35

    attr_reader :decimal, :bits, :delay, :protocol

    def self.parse(data)
      new(*Ban.decode7bit(data).split('|').map(&:to_i))
    end

    def initialize(decimal, bits, delay, protocol)
      @decimal, @bits, @delay, @protocol = decimal, bits, delay, protocol
    end

    def name
      (tristate[-1] == 'F') ? 'rc-turned-on' : 'rc-turned-off'
    end

    def valid?
      tristate
      true
    rescue ArgumentError
      false
    end

    def to_hash
      {
        'decimal' => decimal,
        'bits' => bits,
        'binary' => binary,
        'tristate' => tristate,
        'delay' => delay,
        'protocol' => protocol
      }
    end

    def to_s
      "decimal: #{decimal} (#{bits} bits) binary #{binary} " +
      "tri-state: #{tristate} pulse length: #{delay} (ms) " +
      "protocol: #{protocol}"
    end

    def binary
      ("%#{bits}s" % decimal.to_s(2)).gsub(' ', '0')
    end

    def tristate
      binary.gsub(/[0-9]{2}/) do |match|
        if match == '00'
          '0'
        elsif match == '01'
          'F'
        else
          raise ArgumentError, "#{match} not applicable"
        end
      end
    end
  end
end

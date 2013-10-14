require 'ban/version'
require 'logger'
require 'json'
require 'etc'
require 'tmpdir'

# used gems
require 'eventmachine'
require 'em-websocket'
require 'arduino_firmata'
require 'thor'

module Ban
  Logger = Logger.new(STDOUT)

  # @param [Array<Fixnum>] data 7 bit encoded data from firmata (midi)
  # @return [String] ascii
  def self.decode7bit(data)
    msg = ""
    i = 0
    while i < data.size
      lsb, msb = data[i], data[i + 1]

      if msb == 0
        msg << lsb.chr
      else
        msg << (lsb + 0b10000000).chr
      end
      i += 2
    end
    msg
  end
  
  # @param [String] data the data to convert to midi 7 bit encoded string
  # @return [Array<Fixnum>] array of midi bytes
  def self.encode7bit(data)
    msg = []
    data.each_byte do |byte|
      msg << (byte & 0b01111111) # LSB
      msg << (byte >> 7 & 0b01111111) # MSB
    end
    msg
  end
end

require 'ban/server'
require 'ban/event'
require 'ban/events/door_event'
require 'ban/events/ir_event'
require 'ban/events/rc_event'
require 'ban/board'
require 'ban/cli'

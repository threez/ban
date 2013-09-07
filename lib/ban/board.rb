module Ban
  class Board
    include EventEmitter
    SEND_RC_ON = 0x20
    SEND_RC_OFF = 0x21
    STRING_DATA = 0x71
    EVENTS = {
      DoorEvent::CMD => DoorEvent,
      IrEvent::CMD   => IrEvent,
      RcEvent::CMD   => RcEvent
    }

    def start(path)
      @path = path
      @firmata = ArduinoFirmata.connect @path, nonblock_io: true,
                                        eventmachine: true
      Logger.debug "Firmata Version: #{@firmata.version}"

      arduino = self
      @firmata.on :sysex do |cmd, data|
        arduino.received_sysex(cmd, data)
      end
    end
    
    def close
      @firmata.close
    end

    def received_sysex(event_code, data)
      if klass = EVENTS[event_code]
        emit :event, klass.parse(data)
      else
        emit :error, msg: 'Unknown event!', event_code: event_code, data: data
      end
    end

    def turn_on(address)
      send_command(SEND_RC_ON, address)
    end

    def turn_off(address)
      send_command(SEND_RC_OFF, address)
    end

    def send_command(command, data)
      @firmata.sysex(STRING_DATA, Ban.encode7bit(command.chr + data))
    end
  end
end

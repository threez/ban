module Ban
  class DoorEvent < Event
    CMD = 0x37

    attr_reader :state

    def self.parse(data)
      new(Ban.decode7bit(data).downcase)
    end
    
    def initialize(state)
      @state = state
    end
    
    def name
      open? ? 'door-opened' : 'door-closed'
    end
    
    def to_hash
      { 'state' => @state }
    end
    
    def open?
      @state == 'open'
    end
    
    def to_s
      "door: #{open? ? 'opened' : 'closed'}"
    end
  end
end

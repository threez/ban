require 'faye/websocket'
require 'eventmachine'
require 'json'

def rc_turn(state, address)
  { "rc-turn-#{state}" => { 'address' => address } }.to_json
end

EM.run do
  ws = Faye::WebSocket::Client.new('ws://localhost:8080/')
  light = '11110D'
  
  ws.on :open do |event|
    puts "Connected"
    ws.send(rc_turn(:on, light))
    EM.add_timer(5) { ws.send(rc_turn(:off, light)) }
  end

  ws.on :message do |event|
    p JSON.parse(event.data)
  end

  ws.on :close do |event|
    puts "Connection closed"
  end
end

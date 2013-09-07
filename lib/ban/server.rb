module Ban
  class Server
    include EventEmitter
    def initialize
      @clients = []
    end

    def broadcast(event)
      @clients.each do |client|
        client.send({ event.name => event.to_hash }.to_json)
      end
    end

    def start(interface, port)
      @server = EM::WebSocket.run(host: interface, port: port) do |ws|
        ws.onopen do |handshake|
          Ban::Logger.debug "WebSocket connection open"
          @clients << ws
        end

        ws.onclose do
          Ban::Logger.debug "WebSocket connection closed"
          @clients.delete(ws)
        end

        ws.onmessage do |command_json|
          begin
            command = JSON.parse(command_json)
            emit :command, command
          rescue JSON::ParserError
            Ban::Logger.warn "Received invalid json: #{command_json}"
          end
        end
      end
    end
  end
end

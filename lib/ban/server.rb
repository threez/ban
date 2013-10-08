module Ban
  class Server
    include EventEmitter

    def initialize(user, group, chroot)
      @clients = []
      @user, @group, @chroot = user, group, chroot
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

      # server port has been started
      drop_priviledges!
    end

    def drop_priviledges!
      Ban::Logger.info "Switching to #{@user}:#{@group} into #{@chroot}"
      uid = Etc.getpwnam(@user).uid
      gid = Etc.getgrnam(@group).gid
      Dir.chroot(@chroot)
      Process::Sys.setgid(gid)
      Process::Sys.setuid(uid)
    rescue => ex
      Ban::Logger.warn "Dropping the priviledges didn't work: #{ex}"
    end
  end
end

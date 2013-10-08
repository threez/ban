module Ban
  class CLI < Thor
    option :device, default: nil
    option :port, type: :numeric, default: 8080
    option :interface, type: :string, default: '0.0.0.0'
    option :user, type: :string, default: 'dialout'
    option :group, type: :string, default: 'nobody'
    option :chroot, type: :string, default: Dir.getwd
    option :em_threads, type: :numeric, default: 4
    desc "server", "starts the ban server"
    def server
      device = options[:device]
      interface = options[:interface]
      port = options[:port]

      EM.epoll
      EM.threadpool_size = options[:em_threads]
      EM.run do
        board = Board.new
        server = Server.new(options[:user], options[:group], options[:chroot])

        board.on :event do |event|
          if event.valid?
            Ban::Logger.debug "#{event.class}: #{event}"
            server.broadcast event
          end
        end

        server.on :command do |command|
          Ban::Logger.debug "Received cmd #{command}"
          if options = command['rc-turn-off']
            Ban::Logger.debug "Turn off #{options['address']}"
            board.turn_off(options['address'])
          elsif options = command['rc-turn-on']
            Ban::Logger.debug "Turn on #{options['address']}"
            board.turn_on(options['address'])
          end
        end
        
        trap(:INT) { board.close; EM.stop }
        trap(:TERM) { board.close; EM.stop }

        Ban::Logger.info "Connecting to #{device || 'auto'}"
        board.start(device)
        Ban::Logger.info "Starting WebSocket Server on #{interface}:#{port}"
        server.start(interface, port)
      end
    end
  end
end

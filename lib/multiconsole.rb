
require 'socket'
require 'forwardable'

module Console

  WAIT = 0.1
  
  class Controller
    SCRIPT =
      "require %q[multiconsole]; Console::Daemon.new ARGV.first rescue nil"

    extend Forwardable
    def_delegators( :@client, :puts, :print, :gets, :flush,
                    :sysread, :syswrite, :systell )
    
    def initialize port
      port = port.to_i.to_s
      @server = TCPServer.new port
      t = Thread.new { connect }
      cmd = "ruby -e '#{SCRIPT}' #{port}"

      if ENV['OCRA_EXECUTABLE']
        system 'start', 'socket_cmd.exe', port
      elsif /cygwin|mswin|mingw|bccwin|wince|emx|windows/ =~ RUBY_PLATFORM
        $stdout.puts "ruby -e '#{SCRIPT}' #{port}" if $DEBUG
        system 'start', 'cmd', '/c', cmd
      elsif konsole_exist?
        system "konsole -e \"#{cmd}\" 2>/dev/null"
      else
        raise StandardError, "Platform #{RUBY_PLATFORM} not currently supported."
      end
      sleep WAIT while t.alive?
    end

    def close
      @client.close
      @server.close
    end

    private
    def connect
      @client = @server.accept
    end

    def konsole_exist?
      `konsole --version 2>&1`
    end
  end

  class Daemon
    def initialize port
      while @socket.nil?
        @socket = TCPSocket.new 'localhost', port.to_i rescue nil
        sleep WAIT
      end

      Thread.new do
        while line = $stdin.gets
          @socket.puts line
        end
      end

      while data = @socket.sysread(1024)
        print data
      end
    end
  end
  
end

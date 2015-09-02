
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
      if ENV['OCRA_EXECUTABLE']
        system 'start', 'socket_cmd.exe', port
      elsif not (/cygwin|mswin|mingw|bccwin|wince|emx|windows/ =~ RUBY_PLATFORM).nil?
        $stdout.puts "ruby -e '#{SCRIPT}' #{port}" if $DEBUG
        system 'start', 'cmd', '/c', "ruby -e '#{SCRIPT}' #{port}"
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
  end

  class Daemon
    def initialize port
      while @socket.nil?
        @socket = TCPSocket.new 'localhost', port.to_i rescue nil
        sleep WAIT
      end
      
      while data = @socket.sysread(1024)
        print data
      end
    end
  end
  
end

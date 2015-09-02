
# For use with Ocra

require 'multiconsole'

exit if defined? Ocra

begin
  Console::Daemon.new ARGV.first.to_i
rescue EOFError => e
end


# For use with Ocra

require 'multiconsole'

exit if defined? Ocra

Console::Daemon.new ARGV.first.to_i rescue nil

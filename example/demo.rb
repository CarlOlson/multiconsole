
require 'multiconsole'

exit if defined? Ocra

consoles = 1.times.map do |i|
  console = Console::Controller.new(2000 + i)
  console.puts "\x1b[3#{1 + i};1mhey\x1b[0m"
  console
end

puts consoles.first.gets
consoles.each &:close

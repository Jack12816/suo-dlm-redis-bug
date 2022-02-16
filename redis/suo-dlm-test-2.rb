#!/usr/bin/env ruby

require 'time'
require 'active_support'
require 'active_support/core_ext/time/calculations'
require 'suo'
require 'parallel'

Redis.new(connection: { url: 'redis://localhost:6379/4' }).flushall

def suo
  Suo::Client::Redis.new(
    'test_key',
    connection: { url: 'redis://localhost:6379/4' }
  )
end

res = Parallel.map((1..3).to_a, in_processes: 8) do |idx|
  suo.lock { sleep 2; idx }
end.compact
return if res.empty?
puts "#{Process.pid}: #{res}"

# => 2450991: [1, 2, 3]

#!/usr/bin/env ruby

require 'time'
require 'active_support'
require 'active_support/core_ext/time/calculations'
require 'suo'
require 'parallel'

raise unless Dalli::Client.new('127.0.0.1:11211').flush_all.first

def suo
  Suo::Client::Memcached.new(
    'test_key',
    connection: '127.0.0.1:11211'
  )
end

res = Parallel.map((1..3).to_a, in_processes: 8) do |idx|
  suo.lock { sleep 2; idx }
end.compact
return if res.empty?
puts "#{Process.pid}: #{res}"

# => 2666167: [2] -- yay. works.

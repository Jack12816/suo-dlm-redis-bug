#!/usr/bin/env ruby

# Just make sure that the redis key is set before any lock acquisition occurs,
# at application boot or before deployment -- something like that

require 'time'
require 'active_support'
require 'active_support/core_ext/time/calculations'
require 'suo'
require 'parallel'

# Redis.new(connection: { url: 'redis://localhost:6379/4' }).flushall

def suo
  Suo::Client::Redis.new(
    'test_key',
    connection: { url: 'redis://localhost:6379/4' }
  )
end

# suo.lock { nil }

loop do
  res = Parallel.map((1..8).to_a, in_processes: 8) do |idx|
    suo.lock { sleep 2; idx }
  end.compact
  next if res.empty?
  puts "#{Process.pid}: #{res}"
end

# => 2450991: [1]

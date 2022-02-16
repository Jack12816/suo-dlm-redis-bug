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

def test
  token = suo.lock
  return unless token
  puts "#{Process.pid}: acquired #{token}"
  sleep rand(3..10)
  suo.unlock token
end

puts 'Synchronize processes..'
now = Time.now
start_at = now.change(usec: 0) - (now.sec % 15) + 15
puts "Start at: #{start_at} (in ~#{(start_at - Time.now).round} seconds)"
loop { break if Time.now >= start_at }
puts "Started at: #{Time.now.iso8601(10)}"
puts

loop { test }

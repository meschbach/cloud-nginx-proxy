#!/bin/bash ruby
require "./generator.rb"

#
# TODO: Fix the ARGV issues with using this as a script
#
file = ARGV[0]
if file.nil?
	puts "Usage: #{$0} config"
	puts "Got: #{ARGV[0]}"
	exit -1
end

puts "Using #{file} for input"
contents = File.read( file )
puts translate( contents, ["http://localhost:3232", "http://localhost:3233"] )

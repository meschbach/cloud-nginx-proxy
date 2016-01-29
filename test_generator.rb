require "./generator.rb"

file = ARGV[1]
puts "Using #{file} for input"
contents = File.read( file )
puts translate( contents, ["http://localhost:3232", "http://localhost:3233"] )

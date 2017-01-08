require 'rspec'

feature_support_dir = File.dirname( __FILE__ )
feature_dir = File.dirname( feature_support_dir )
base_dir = File.dirname( feature_dir )
lib_dir = File.join( base_dir, "lib" )

puts "*** Library directory: #{lib_dir}"

$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'cnp/template.rb'

RSpec.configure do |config|
	config.expect_with :rspec do |c|
		c.syntax = [:should, :expect]
	end
end

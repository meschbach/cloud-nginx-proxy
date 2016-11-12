require 'rspec'
require File.join( File.dirname( __FILE__ ), "common_features" )

class Spinach::Features::ReverseProxyingHttp < Spinach::FeatureSteps
	include CommonFeatures
  step 'I have an HTTP site configured' do
		@host_name = 'example.invalid'
		@upstream_name = 'plain-http'
		@descriptor = OpenStruct.new(
			:name => @upstream_name,
			:host => @host_name,
			:http => {}
		)
  end
end


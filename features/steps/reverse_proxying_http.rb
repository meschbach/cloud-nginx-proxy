require 'rspec'

class Spinach::Features::ReverseProxyingHttp < Spinach::FeatureSteps
  step 'I have an HTTP site configured' do
		@host_name = 'example.invalid'
		@descriptor = OpenStruct.new(
			:name => "plain-http",
			:host => @host_name,
			:http => {}
		)
  end

  step 'the configuration is activated' do
		upstreams = ["upstream.invalid"]
		@host_config = CNP.translate_host( @descriptor, upstreams )
  end

  step 'the HTTP nginx configuration is correctly generated' do
		@host_config.should include( "listen *:80;" )
		@host_config.should include( "server_name #{@host_name};" )
  end
end

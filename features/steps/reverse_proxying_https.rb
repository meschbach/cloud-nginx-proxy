require 'rspec'
require File.join( File.dirname( __FILE__ ), "common_features" )

class Spinach::Features::ReverseProxyingHttps < Spinach::FeatureSteps
	include CommonFeatures

  step 'I have an HTTPS site configured' do
		@key_file = '/x509/private'
		@certificate_file = '/x509/public'

		@host_name = 'example.invalid'
		@upstream_name = 'https_upstreams'
		@descriptor = OpenStruct.new({
			"name" => @upstream_name,
			"host" => @host_name,
			"http" => {},
			"https" => {
				"key" => @key_file,
				"certificate" => @certificate_file
			}
		})
  end

end

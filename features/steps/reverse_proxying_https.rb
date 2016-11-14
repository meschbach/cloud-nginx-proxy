Given 'I have an HTTPS site configured' do
	@key_file = '/x509/private'
	@certificate_file = '/x509/public'

	@host_name = 'example.invalid'
	@upstream_name = 'https_upstreams'
	@descriptor = OpenStruct.new({
		"name" => @upstream_name,
		"host" => @host_name,
		"https" => {
			"key" => @key_file,
			"certificate" => @certificate_file
		}
	})
end

Given(/^allows (\d+)M to be uploaded to '\/example\-upload'$/) do |size|
	@upload_point = {
		"/example-upload" => {
			"request_body_limit" => "256M"
		}
	}

	@descriptor["https"]["locations"] = @upload_point
end

Then(/^the location '\/example\-upload' passes the proxy$/) do
	# TODO: need to improve how the tests understand the configuration
	@host_config.should match /location\s\/example\-upload\s{(\s*)proxy_pass\shttp\:\/\/https_upstreams;/
end

Then(/^the location '\/example\-upload' allows for (\d+)M$/) do |size|
	result = /location\s\/example\-upload\s\{([^\}])*\}/.match( @host_config )
	result[0].should match /client_max_body_size\s#{size}M;/
end

Then(/^the location '\/example\-upload' imports the proxy configuration$/) do
	result = /location\s\/example\-upload\s\{([^\}])*\}/.match( @host_config )
	result[0].should match /include(\s+)proxy_params/
end

Given(/^the HTTPS site is configured to redirect HTTP traffic$/) do
	http = {} || @descriptor["http"]
	http["https-redirect"] = true
	@descriptor["http"] = http
end

Then(/^HTTP traffic is redirected$/) do
	#puts "#{@host_config}"
	servers = @host_config.scan(/server\s+\{[^\}]*\}/)
	servers[1].should include "return 301 https://$server_name$request_uri;"
end

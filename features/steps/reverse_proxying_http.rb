Given 'I have an HTTP site configured' do
	@host_name = 'example.invalid'
	@upstream_name = 'plain-http'
	@descriptor = OpenStruct.new(
		:name => @upstream_name,
		:host => @host_name,
		:http => {}
	)
end

Given(/^the HTTP site is configured to listen on port (\d+)$/) do |port|
	@descriptor[:http]["connector"] = {"port" => port }
end

Then(/^the host name is correct$/) do
	@host_config.should include( "server_name #{@host_name};" )
end

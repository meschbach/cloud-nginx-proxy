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
	http = @descriptor[:http]
	connector = http["connector"] || {}
	http["connector"] = connector
	if connector["ports"]
		connector["ports"].push( port )
	else
		connector["ports"] = [port]
	end
end

Then(/^the host name is correct$/) do
	@host_config.should include( "server_name #{@host_name};" )
end

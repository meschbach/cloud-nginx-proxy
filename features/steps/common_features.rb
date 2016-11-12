When 'the configuration is activated' do
	@upstream_server = "upstream.invalid"
	upstreams = [ @upstream_server ]
	@host_config = CNP.translate_host( @descriptor, upstreams )
end

Then 'the hostname and port are correct' do
	@host_config.should include( "listen *:80;" )
	@host_config.should include( "server_name #{@host_name};" )
end

Then 'the upstreams are generated' do
	@host_config.should include( "upstream #{@upstream_name} {" )
	@host_config.should include( "server #{@upstream_server}" )
end

Then 'all traffic is passed to the backends' do
	@host_config.should include( "location / {" )
	@host_config.should include( "proxy_pass" )
end

Then(/^the hostname is correct$/) do
	@host_config.should include( "server_name #{@host_name};" )
end

Then /^listening on port (\d+)$/ do |port|
	@host_config.should include( "listen *:#{port}" )
end

Then /^not listening on port (\d+)$/ do |port|
	@host_config.should_not include( "listen *:#{port}" )
end

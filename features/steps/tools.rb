require 'cnp/tools'

Given(/^I have registered the following host$/) do |string|
	host_registration = CNP::Tools::RegisterHost.new( @system )
	host_registration.from_json_text( string )
end

When(/^I run the catch up command$/) do
	catchup = CNP::Tools::CatchUp.new( @system )
	@host_config = catchup.as_text
	puts "Host config: #{@host_config}"
	@conf = MEE::Nginx::Parser.parse( @host_config )
end

Then(/^for host "([^"]*)" should redirect from port (\d+) to port (\d+)$/) do |hostName, insecure_port, secure_port|
	named_port = secure_port == 443 ? "" : ":#{secure_port}"
	return_command = "return 301 https://$server_name$request_uri"

	@conf.blocks_named( "server" ).select { |server|
		server.path_exists?( ["listen *:#{insecure_port}"] ) and server.path_exists?( [ return_command ] )
	}.empty?.should be false
end

require 'cnp/etcd'

Given(/^I have configured EtcD\-V2 for root \/test\/v2$/) do
	@etcdv2 = CNP::EtcD::V2.new( "/test/v2" )
end

When(/^I register a simple site and upstream using EtcD\-V2$/) do
	@host_name = "simple.v2.etcd.example.invalid"
	@etcdv2.register_host( @host_name, "simple-site" )
	@etcdv2.register_upstream( "simple-site", "local@8080", "http://localhost@8080" )
end

Then(/^the configuration should activate with the default connectors$/) do
	@etcdv2.host_names.should include( @host_name )
	host = @etcdv2.host( @host_name )
	host.connectors.should include( "default" )
end

require 'cnp/etcd'

Given(/^I have configured EtcD for root \/test\/v1\/registration$/) do
	base = "/test/v1/registration"
	@etcd_layer = CNP::EtcD::V1.new( base )
end

When(/^I register a simple host configuration with EtcD$/) do
	configuration = {
		:name => "simple-name",
		:host => "simple.invalid",
		:http => {}
	}
	@etcd_layer.register_host( configuration.to_json )
end

Then(/^the host is visible to the application with EtcD$/) do
	@etcd_layer.hosts.should include("simple.invalid")
end

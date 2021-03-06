require 'cnp/etcd'
require 'cnp'
require 'mee/nginx/parser'

Given(/^I have configured EtcD\-V2 for root \/test\/v2$/) do
	@etcdv2 = CNP::EtcD::V2::Storage.new( "/test/v2" )
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

Given(/^I have a register EtcD\-V(\d+) storage in the system$/) do |arg1|
	@system = CNP::System.new
	@system.register_storage( CNP::EtcD::V2::Storage.new( '/test/v2' ) )
end

When(/^reigster the host with connector '([^']+)' and upstream '([^']+)'$/) do |connector, upstream|
	host = @system.register_host( @host_name, upstream )
	host.use_connector( connector )
end

Given(/^the host name is '([^']*)'$/) do |host_name|
	@host_name = host_name
end

Given(/^the upstream is '([^']*)'$/) do |upstream|
	@upstream = upstream
end

When(/^I register the EtcD\-V2 connector '([^']*)' for HTTP with ports (\d+) and (\d+)$/) do |name, port1, port2|
	@connector_builder = @system.register_connector( name )
	@connector_builder.register_port( 'private', port1 )
	@connector_builder.register_port( 'public', port2 )
end

When(/^I register a connector '([^']+)' for TLS on port (\d+)$/) do |name, port|
	@connector_builder = @system.register_connector( name, 'tls' )
	@connector_builder.register_port( "default", port )
end

When(/^upstream '([^']+)' for upstream '([^']+)'$/) do |upstream, url|
	@system.register_upstream( upstream, "default", url )
end

When(/^ask the system to generate the configuration for the site$/) do
	@host_config = @system.generate_for( @host_name )
	@conf = MEE::Nginx::Parser.parse( @host_config )
end

When(/^I register host '([^']+)' to use connector '([^']+)' and upstream '([^']+)'$/) do |host, connector, upstream|
	@host_name = host
	host = @system.register_host( host, upstream )
	host.use_connector( connector )
end

When(/^register the upstream '([^']+)' with '([^']+)' named '([^']+)'$/) do |upstream, url, name|
	@system.register_upstream( upstream, name, url )
end

When(/^I register host '([^']+)' to use certificate '([^']+)' and key '([^']+)'$/) do |host, certificate, key|
	@system.register_host( host ).use_asymmetric_key( certificate, key )
end

Then(/^is using the certificate '([^']+)'$/) do |certificate|
	@conf.path_exists?( ["server", "ssl_certificate #{certificate}"] ).should be true
end

Then(/^is using the key '([^']+)'$/) do |key|
	@conf.path_exists?( ["server", "ssl_certificate_key #{key}"] ).should be true
end

Given(/^connector '([^']+)' configured for TLS on port (\d+)$/) do |connector_name, port|
	connector = @system.register_connector( connector_name, 'tls' )
	connector.register_port( "tls#{port}", port )
	connector
end

Given(/^have host '([^']+)' use connector '([^']+)'$/) do |host, connector|
	host = @system.register_host( host )
	host.use_connector( host.connectors.push( connector ) )
end

#!/bin/bash ruby

require 'etcd'
require 'json'

#
# Registers a given host for to be services by the load balancer
#
class RegisterHost
	def register( prefix, host, config_contents)
		base_path = prefix + host
		etcdctl = Etcd.client
		node_path = base_path + "/config"
		etcdctl.set( node_path, value: config_contents )
	end
end

#
# CLI
#
require 'trollop'
opts = Trollop::options do
	opt :etcd_prefix, "etcd load balancer prefix", :default => "/lb"
	opt :host_name, "Host name to configure", :default => "example.test"
	opt :config_file, "Configuration file to be loaded", :type => :string, :required => true
end

etcd_prefix = opts[:etcd_prefix]
host_name = opts[:host_name]
config_contents = File.read( opts[:config_file] )

RegisterHost.new.register( etcd_prefix, host_name, config_contents )

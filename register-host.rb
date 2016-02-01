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

host_name = "example.test"
config_contents = File.read("test.json")
RegisterHost.new.register( "/lb/", host_name, config_contents )

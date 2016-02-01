#!/bin/bash ruby

require 'etcd'

#
# Register's the given service as available for load balancing
#
class RegisterClient
	def register( prefix, host, name, url )
		base_path = prefix + host
		etcdctl = Etcd.client
		node_path = base_path + "/" + name
		puts "Updating #{node_path} -> #{url}"
		etcdctl.set( node_path, value: url )
	end
end

node_name = ARGV.length > 1 ? ARGV[1] : "node-0"
node_url = ARGV[0]  || "http://localhost:9292"
RegisterClient.new.register( "/lb/", "example.test", node_name, node_url)

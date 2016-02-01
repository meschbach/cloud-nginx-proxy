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

#
# CLI
#
require 'trollop'
opts = Trollop::options do
	opt :etcd_prefix, "etcd load balancer prefix", :default => "/lb"
	opt :host_name, "Host name to configure", :default => "example.test"
	opt :node_name, "etcd key to store the upstream under", :type => :string, :required => true
	opt :node_url, "URL to provide as upstream for the Load Balancer", :type => :string, :required => true
end

etcd_prefix = opts[:etcd_prefix]
host_name = opts[:host_name]
node_name = opts[:node_name]
node_url = opts[:node_url]

RegisterClient.new.register( etcd_prefix, host_name, node_name, node_url)

#!/bin/bash ruby
########################################
#
#
# For each proxied host, if there is an upstr
########################################
require "cnp/output"

require 'etcd'

class CatchUp
	def main( config )
		begin
			@etcd = Etcd.client
			base_dir = @etcd.get( config.etcd_prefix ).node
			if not base_dir.directory?
				puts "WARNING: EtcD base key #{config.etcd_prefix} is not a directory"
			else
				generator = CNP::ErbConfigGenerator.new( config.lb_dir, config.etcd_prefix, config.template, config.notify_key )
				base_dir.children.each do |child|
					generator.generate_for_etcd( child.key )
				end
			end
		rescue Etcd::KeyNotFound => e
			puts "WARNING: configuration key (#{config.etcd_prefix}) not found"
		end
	end
end

#
# CLI
#
require 'trollop'
opts = Trollop::options do
	opt :etcd_prefix, "etcd load balancer prefix", :default => "/lb"
	opt :lb_dir, "Place to store the load balancer configurations files", :type => :string, :required => true
	opt :notify_key, "Key to notify nginx on the target host to reload the configuration", :type => :string
	opt :template, "Use an alternative ERB template for dpeloyment", :type => :string
end

CatchUp.new.main( opts )

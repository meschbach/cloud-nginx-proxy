#!/bin/bash ruby
require "./generator.rb"

require 'etcd'

class EtcdHostConfig
	def initialize( host_base )
		@etcd = Etcd.client
		@base_path = host_base
		puts "Using #{@base_path} for host configuration"
	end

	def config
		info = @etcd.get( @base_path + "/config" )
		value = info.value
		config_contents = JSON.parse( value )
		return config_contents
	end

	def upstreams
		puts @base_path
		list = @etcd.get( @base_path )
		upstreams = list.children.map do |child|
			if child.directory? || child.key.end_with?("config")
				nil
			else
				child.value
			end
		end.reject { |upstream| upstream.nil? }
		puts "Upstreams: #{upstreams}"
		return upstreams
	end
end

class EtcdExecWatcherBridge
	def initialize( opts )
		@etcd_key_prefix = opts[:etcd_prefix]
		@etcd_key_prefix += "/" unless @etcd_key_prefix.end_with? "/"
		@lb_dir = opts[:lb_dir]
		@notify_key = opts[:notify_key]

		@template = opts[:template]
	end

	#
	# TOOD: Make configurable
	#
	def etcd_key_prefix
		@etcd_key_prefix
	end

	def changed_key
		ENV["ETCD_WATCH_KEY"] or raise "EtcD watch key not found"
	end

	def changed_value
		ENV["ETCD_WATCH_VALUE"] or raise "EtcD watch value not found"
	end

	def lb_key_parts
		unless changed_key.start_with? etcd_key_prefix
			puts "ERROR: prefix mismatch, got #{changed_key}, expected to start with #{etcd_key_prefix}"
			exit -2
		end
		modified_key = changed_key[etcd_key_prefix.length..-1]
		puts "Updating becuase #{changed_key} has changed, host specific key: #{modified_key}."

		parts = modified_key.split("/")

		if parts.length < 2
			puts "Can't pull out intent from path: #{changed_key} (#{modified_key})"
			exit -3
		end

		parts
	end

	def etcd_exec
		parts = lb_key_parts
		host = parts[0]
		type = parts[1]
		update( host )
	end

	def update( host )
		host_root = etcd_key_prefix + host
		puts "Host configuration root #{host_root}"
		host = EtcdHostConfig.new( host_root )
		config = host.config
		upstreams = host.upstreams
		result = translate_host( config, upstreams, @template )

		target_file = @lb_dir + "/" + host.config["name"]
		puts "Writing to #{target_file}"
		File.write( target_file, result )

		if @notify_key
			client = Etcd.client
			client.set( @notify_key, value: "Updated #{host} @" + DateTime.now.to_s )
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

EtcdExecWatcherBridge.new(opts).etcd_exec

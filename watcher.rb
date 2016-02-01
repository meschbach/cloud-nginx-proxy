#!/bin/bash ruby
require "./generator.rb"

require 'etcd'

class EtcdHostConfig
	def initialize( host_base )
		@etcd = Etcd.client
		@base_path = host_base
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
	#
	# TOOD: Make configurable
	#
	def etcd_key_prefix
		"/lb/"
	end

	def changed_key
		ENV["ETCD_WATCH_KEY"]
	end

	def changed_value
		ENV["ETCD_WATCH_VALUE"]
	end

	def lb_key_parts
		unless changed_key.start_with? etcd_key_prefix
			puts "ERROR: prefix mismatch, got #{etcd_key}, expected to start with #{prefix}"
			exit -2
		end
		modified_key = changed_key[etcd_key_prefix.length..-1]

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
		host = EtcdHostConfig.new( etcd_key_prefix + host )
		config = host.config
		upstreams = host.upstreams
		result = translate_host( config, upstreams )

		target_file = ARGV[0]  + "/" + host.config["name"]
		puts "Writing to #{target_file}"
		File.write( target_file, result )
	end
end

EtcdExecWatcherBridge.new.etcd_exec

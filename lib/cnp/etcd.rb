########################################
#
#
# EtcD bindings
########################################
require 'etcd'

module CNP
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
			puts  "Config: #{config_contents.inspect}"
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

	module EtcD
		class V1
			def initialize( storage_prefix )
				storage_prefix += "/" unless storage_prefix.end_with? "/"
				@storage_prefix = storage_prefix
			end

			def register_host( json )
				info = JSON.parse( json )
				raise "Key 'host' is missing and required" unless info["host"]
				node_path = @storage_prefix + info["host"] + "/config"

				etcdctl = Etcd.client
				etcdctl.set( node_path, value: json )
			end

			def hosts
				etcdctl = Etcd.client
				prefix_node = etcdctl.get( @storage_prefix ).node
				raise "Node #{storage_prefix} is not a directory" unless prefix_node.directory?

				prefix_node.children.map do |host_nodes|
					fully_qualified_name = host_nodes.key
					split_name = fully_qualified_name.split( "/" )
					host_name = split_name[-1]
					puts host_name
					host_name
				end
			end
		end
	end
end

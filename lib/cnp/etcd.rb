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

			def host_names
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

		class V2
			def initialize( storage_prefix )
				storage_prefix += "/" unless storage_prefix.end_with? "/"
				@storage_prefix = storage_prefix
			end

			def register_host( host, upstream )
				host_config_path = @storage_prefix + "hosts/" + host
				upstreams_path = host_config_path + "/upstream"

				etcdctl = etcd_client
				etcdctl.set( upstreams_path, value: upstream )
				V2_Host.new( host_config_path, host, etcdctl )
			end

			def register_upstream( upstream, name, url )
				upstream_config_path = @storage_prefix + "upstreams" + "/" +upstream + "/" + name

				etcdctl = etcd_client
				etcdctl.set( upstream_config_path, value: url )
			end

			def register_connector( name, type )
				connector_path = @storage_prefix + "connectors/"
				key_name = connector_path + name
				if etcd_client.exists?( key_name )
					raise "Expected directory got other for #{key_name}" unless etcd_client.get( key_name ).directory?
					etcd_client.set( key_name + "/config/type", value: type )
				else
					etcd_client.set( key_name + "/config/type", value: type )
				end
				V2_Connector.new( key_name, etcd_client )
			end

			def host_names
				etcdctl = etcd_client
				prefix_node = etcdctl.get( @storage_prefix + "hosts" ).node
				raise "Node #{storage_prefix} is not a directory" unless prefix_node.directory?

				prefix_node.children.map do |host_nodes|
					fully_qualified_name = host_nodes.key
					split_name = fully_qualified_name.split( "/" )
					host_name = split_name[-1]
					host_name
				end
			end

			def host( name )
				etcdctl = etcd_client
				host_key_base = @storage_prefix + "hosts/" + name
				V2_Host.new( host_key_base, name, etcdctl )
			end

			def upstream( name )
				upstream_base = @storage_prefix + "upstreams/" + name
				V2_Upstream.new( upstream_base, name, etcd_client )
			end

			def connector( name )
				key = @storage_prefix + "connectors/" + name
				V2_Connector.new( key, etcd_client )
			end

			private
			def etcd_client
				etcdctl = Etcd.client
			end
		end

		class V2_Host
			def initialize( host_base, host_name, etcdctl )
				@host_base = host_base
				@host_name = host_name
				@etcdctl = etcdctl
			end

			def host_name; @host_name; end

			def use_connector( name )
				@etcdctl.set( @host_base + "/connectors", value: name )
				self
			end

			def connectors
				connectors = @host_base + "/connectors"
				if @etcdctl.exists? connectors
					connector_names = @etcdctl.get( connectors )
					[connector_names.value]
				else
					["default"]
				end
			end

			def upstream
				upstream_key = @host_base + "/upstream"
				if @etcdctl.exists?( upstream_key )
					@etcdctl.get( upstream_key ).value
				else
					"default"
				end
			end
		end

		class V2_Connector
			def initialize( key_base, etcdctl )
				@base = key_base
				@etcdctl = etcdctl
			end

			def register_port( name, port )
				key = @base + "/ports/" + name
				@etcdctl.set( key, value: port )
			end

			def type
				node = @etcdctl.get( @base +"/config/type" )
				node.value
			end

			def listeners
				node = @etcdctl.get( @base +"/ports" )
				node.children.map do |connector_node|
					connector_node.value
				end
			end
		end

		class V2_Upstream
			def initialize( key, name, etcdctl )
				@base = key
				@name = name
				@etcd_client = etcdctl
			end

			def output_details
				node = @etcd_client.get( @base )
				raise "Expected upstream '#{@base}' to be a directory" unless node.directory?
				upstreams = node.children.map do |child|
					child.value
				end.reject { |upstream| upstream.nil? }
				return upstreams
			end
		end
	end
end

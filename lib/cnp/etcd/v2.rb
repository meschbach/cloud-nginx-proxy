########################################
#
#
# EtcD V2 bindings
########################################

module CNP
	module EtcD
		module V2
			class Storage
				def initialize( storage_prefix )
					storage_prefix += "/" unless storage_prefix.end_with? "/"
					@storage_prefix = storage_prefix
				end

				def register_host( host, upstream )
					host_config_path = @storage_prefix + "hosts/" + host

					etcdctl = etcd_client
					host = Host.new( host_config_path, host, etcdctl )
					host.use_upstream( upstream )
					host
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
					Connector.new( key_name, etcd_client )
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
					Host.new( host_key_base, name, etcdctl )
				end

				def upstream( name )
					raise "Expected upstream named, got empty or nil" if (name.nil? or name.empty?)
					upstream_base = @storage_prefix + "upstreams/" + name
					Upstream.new( upstream_base, name, etcd_client )
				end

				def connector( name )
					key = @storage_prefix + "connectors/" + name
					Connector.new( key, etcd_client )
				end

				private
				def etcd_client
					etcdctl = Etcd.client
				end
			end

			class Host
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
					if @etcdctl.exists?( upstream_key )
						node = @etcdctl.get( upstream_key )
						value = node.value
						raise "Storage error: upstream is nil but exists" if (value.nil? or value.empty?)
						value
					else
						"default"
					end
				end

				def use_upstream( upstream_name )
					raise "Storage constraint: upstream my be a valid name" if (upstream_name.nil? or upstream.empty?)
					@etcdctl.set( upstream_key, value: upstream_name )
				end

				def use_asymmetric_key( certificate, key )
					@etcdctl.set( certificate_key, value: certificate )
					@etcdctl.set( private_key, value: key )
				end

				def asymmetric_certificate
					@etcdctl.get( certificate_key ).value
				end

				def asymmetric_key
					@etcdctl.get( private_key ).value
				end

				private
				def upstream_key; @host_base + "/upstream"; end
				def certificate_key; @host_base + "/certificate"; end
				def private_key; @host_base + "/key"; end
			end

			class Connector
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

			class Upstream
				def initialize( key, name, etcdctl )
					raise "key must be a valid value" if key.nil? or key.empty?
					@key = key
					@name = name
					@etcd_client = etcdctl
				end

				def output_details
					node = @etcd_client.get( @key )
					raise "Expected upstream '#{@key}' to be a directory" unless node.directory?
					upstreams = node.children.map do |child|
						child.value
					end.reject { |upstream| upstream.nil? }
					return upstreams
				end
			end
		end
	end
end

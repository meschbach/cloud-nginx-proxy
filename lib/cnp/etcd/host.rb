########################################
#
#
# EtcD V2 bindings
########################################

module CNP
	module EtcD
		module V2
			class Host
				def initialize( host_base, host_name, etcdctl )
					@host_base = host_base
					@host_name = host_name
					@etcdctl = etcdctl
				end

				def host_name; @host_name; end

				def use_connector( name )
					@etcdctl.set( @host_base + "/connectors", value: Array(name).to_json )
					self
				end

				def connectors
					connectors = @host_base + "/connectors"
					if @etcdctl.exists? connectors
						connector_names = @etcdctl.get( connectors )
						JSON.parse( connector_names.value )
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
					raise "Certificate required for #{@host_name}" unless certificate
					raise "Key required for #{@host_name}" unless key
					@etcdctl.set( certificate_key, value: certificate )
					@etcdctl.set( private_key, value: key )
				end

				def asymmetric_certificate
					get_key certificate_key
				end

				def asymmetric_key
					get_key private_key
				end

				def use_https_only( flag )
					@etcdctl.set( redirect_http_key, value: !!flag )
				end

				def redirect_to_https
					if @etcdctl.exists?( redirect_http_key )
						node = @etcdctl.get( redirect_http_key )
						node ? node.value : false
					else
						false
					end
				end

				def with_location( path )
					a_path = locations.select { |l| l.path == path }
					return a_path[0] unless a_path.empty?

					id = SecureRandom.uuid
					location_key = @host_base + "/locations/" + id
					entity = LocationSettings.new( location_key, @etcdctl )
					entity.path = path
					entity
				end

				def locations
					location_key = @host_base + "/locations"
					return [] unless @etcdctl.exists? location_key
					node = @etcdctl.get( location_key )
					node.children.map do |location_node|
						key = location_node.key
						LocationSettings.new( key, @etcdctl )
					end
				end

				private
				def get_key( key_name )
					raise "Unable to locate key #{key_name}" unless @etcdctl.exists?( key_name )
					@etcdctl.get( key_name ).value
				end

				def redirect_http_key; @host_base + "/secure-only"; end
				def upstream_key; @host_base + "/upstream"; end
				def certificate_key; @host_base + "/certificate"; end
				def private_key; @host_base + "/key"; end
			end
		end
	end
end

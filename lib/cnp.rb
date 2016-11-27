
module CNP
	class System
		def initialize
		end

		def register_storage( storage )
			raise "Only supports one storage layer currently" unless @storage.nil?
			@storage = storage
		end

		def register_host( host_name, upstream_name = nil )
			raise "storage layer needs to be registered" if @storage.nil?
			@storage.register_host( host_name, upstream_name )
		end

		def register_connector( name, type = 'http' )
			raise "storage layer needs to be registered" if @storage.nil?
			@storage.register_connector( name, type )
		end

		def register_upstream( upstream, name, url )
			raise "storage layer needs to be registered" if @storage.nil?
			@storage.register_upstream( upstream, name, url )
		end

		# generates a configuration for a givne host
		def generate_for( host_name )
			host = @storage.host( host_name )
			upstream = @storage.upstream( host.upstream )

			host_config = {
				"host" => host.host_name,
				"name" => host.upstream
			}

			http_ports = []
			https_ports = []
			host.connectors.each do |connector_name|
				connector =  @storage.connector( connector_name )
				if connector.type == "http"
					connector.listeners.each do |p|
						http_ports.push( p )
					end
				elsif connector.type == "tls"
					connector.listeners.each do |p|
						https_ports.push( p )
					end
				else
					raise "Expected type (http|tls), got '#{connector.type}'"
				end
			end

			unless http_ports.empty?
				host_config["http"] = {
					"connector" => {
						"ports" => http_ports
					}
				}
			end

			unless https_ports.empty?
				host_config["https"] = {
					"certificate" => "/private/certificate",
					"key" => "/private/key"
				}
			end
			CNP::translate_host( host_config, upstream.output_details )
		end
	end
end

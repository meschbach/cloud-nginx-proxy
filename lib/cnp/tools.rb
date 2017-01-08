require 'json'

module CNP
	module Tools
		class RegisterHost
			def initialize( system )
				@system = system
			end

			def from_json_text( plain_text )
				details = JSON.parse( plain_text )

				host = @system.register_host( details["host"], details["name"] )
				if details["https"]
					https = details["https"]
					if (https["key"] and https["certificate"])
						host.use_asymmetric_key( https["certificate"], https["key"] )
						host.use_connector( ["default", "default-https" ] )
					end

					( https["locations"] || [] ).each do |location, value|
						location = host.with_location( location )
						location.request_body_size = value["request_body_limit"]
					end
				end
				host.use_https_only( true ) if ( details["http"] && details["http"]["https-redirect"] )
			end
		end

		class CatchUp
			def initialize( system )
				@system = system
			end

			def as_text
				buffer = ""
				@system.host_names.each do |hostname|
					buffer = buffer + @system.generate_for( hostname )
				end
				buffer
			end
		end
	end
end

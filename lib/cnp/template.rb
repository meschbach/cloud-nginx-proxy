########################################
#
#
#
########################################
#
#
#
require 'json'
require 'erb'

module CNP
	#
	#
	#
	class TemplateEval
		def initialize( descriptor, upstream )
			if upstream && upstream.services && !upstream.services.empty?
				@upstreams = upstream
			else
				raise "upstreams must be defined."
			end
			@descriptor = descriptor
		end

		def https
			unless @descriptor["https"]
				return false
			end
			https = @descriptor["https"]

			descriptor = OpenStruct.new({
				:host => @descriptor["host"],
				:certificate => https["certificate"],
				:key => https["key"],
				:locations => extract_locations_from_hash( @descriptor["https"] )
			})
		end

		def http
			unless @descriptor["http"]
				return false
			end

			http_descriptor = @descriptor["http"]
			connector_description = http_descriptor["connector"] || {}
			if connector_description["ports"]
				ports = connector_description["ports"] || []
			else
				port = connector_description["port"] || 80
				ports = [port]
			end

			descriptor = OpenStruct.new
			descriptor.host = @descriptor["host"]
			descriptor.redirect_to_https = @descriptor["http"]["https-redirect"]
			descriptor.locations = extract_locations_from_hash( @descriptor["http"] )
			descriptor.connector = OpenStruct.new( :ports => ports )
			descriptor
		end

		def extract_locations_from_hash( config )
			locations = (config["locations"] || {}).map do |key, value|
				mount = OpenStruct.new
				mount.path = key
				mount.request_body_limit = value["request_body_limit"] if value["request_body_limit"]
				mount
			end
			locations
		end

		def upstreams
			@upstreams
		end

		def method_missing(m, *args, &block)
			#puts "Warning: method missing #{m}"
			false
		end

		def get_binding
			binding
		end
	end

	#
	#
	#
	def self.translate( input, upstreams )
		descriptor = JSON.parse( input )
		translate_host( descriptor, upstreams )
	end

	#
	#
	#
	def self.translate_host( descriptor, upstreams, templateFile = nil )
		unless descriptor["name"]
			raise "'name' field must be provided to configure upstreams"
		end
		unless descriptor["host"]
			raise "'host' field must be provied"
		end
		if descriptor["https"]
			https = descriptor["https"]
			unless https["key"]
				raise "https.key => private key file name missing"
			end
			unless https["certificate"]
				raise "https.certificate => certificate chain file name missing"
			end
		end

		if templateFile.nil?
			cnp_dir = File.dirname( __FILE__ )
			lib_dir = File.dirname( cnp_dir )
			base_dir = File.dirname( lib_dir )
			templateFile = File.join( base_dir, "template.erb" )
		end
		templateContent = File.read( templateFile )

		services = OpenStruct.new
		services.name =  descriptor["name"] || "default-upstream"
		#TODO: This should be a logged statement
		puts "Upstream name: #{services.name}"
		services.services = upstreams

		b = TemplateEval.new( descriptor, services ).get_binding
		erb = ERB.new( templateContent )
		erb.result(b)
	end
end

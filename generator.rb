#
#
#
require 'json'
require 'erb'

#
#
#
class TemplateEval
	def initialize( descriptor, upstream )
		if upstream && upstream.services && !upstream.services.empty?
			@upstreams = upstream
		else
			@upstreams = false
		end
		@descriptor = descriptor
	end

	def https
		unless @descriptor["https"]
			return false
		end
		https = @descriptor["https"]

		descriptor = OpenStruct.new
		descriptor.host = @descriptor["host"]
		descriptor.certificate = https["certificate"]
		descriptor.key = https["key"]
		descriptor
	end

	def http
		unless @descriptor["http"]
			return false
		end

		descriptor = OpenStruct.new
		descriptor.host = @descriptor["host"]
		descriptor.redirect_to_https = @descriptor["http"]["https-redirect"]
		descriptor
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
def translate( input, upstreams )
	descriptor = JSON.parse( input )
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

	templateContent = File.read( "template.erb" )

	services = OpenStruct.new
	services.name =  descriptor["name"] || "default-upstream"
	services.services = upstreams

	puts services

	b = TemplateEval.new( descriptor, services ).get_binding
	erb = ERB.new( templateContent )
	erb.result(b)
end

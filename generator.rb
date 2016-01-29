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
		descriptor = OpenStruct.new
		descriptor.host = @descriptor["host"]
		descriptor
	end

	def http
		descriptor = OpenStruct.new
		descriptor.host = @descriptor["host"]
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
	templateContent = File.read( "template.erb" )

	services = OpenStruct.new
	services.name =  descriptor["name"] || "default-upstream"
	services.services = upstreams

	puts services

	b = TemplateEval.new( descriptor, services ).get_binding
	erb = ERB.new( templateContent )
	erb.result(b)
end

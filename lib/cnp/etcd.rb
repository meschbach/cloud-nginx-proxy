########################################
#
#
# EtcD bindings
########################################
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
end

########################################
#
#
#
########################################
require 'cnp/etcd'
require 'cnp/template'

module CNP
	class ErbConfigGenerator
		def initialize( output_base, etcd_prefix, template )
			@output_base = output_base
			@etcd_prefix = etcd_prefix
			@template = template
		end

		def etcd_key_prefix
			@etcd_prefix
		end

		def generate_upstream( host, config, upstreams )
			result = CNP::translate_host( config, upstreams, @template )

			target_file = @output_base + "/" + host.config["name"]
			puts "Writing to #{target_file}"
			if !Dir.exist? @output_base
				puts "Creating directory"
				Dir.mkdir( @output_base )
			end
			File.write( target_file, result )
		end

		def delete_upstream( host )
			host_name = host.config["name"]
			raise "Host name contains insecure character" if host_name.include? "/"
			puts host_name

			target_file = @output_base + "/" + host_name
			if File.exist? target_file
				File.delete( target_file )
			end
		end

		def generate_for_etcd( host_root )
			puts "Host configuration root #{host_root}"
			host = EtcdHostConfig.new( host_root )
			config = host.config
			upstreams = host.upstreams
			if upstreams && upstreams.length > 0
				generate_upstream( host, config, upstreams )
			else
				puts "No upstreams, skpping configuration"
				delete_upstream( host )
			end

			if @notify_key
				client = Etcd.client
				client.set( @notify_key, value: "Updated #{host} @" + DateTime.now.to_s )
			end
		end
	end
end

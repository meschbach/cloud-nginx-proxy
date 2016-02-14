########################################
#
#
#
########################################

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

class ErbConfigGenerator
	def initialize( output_base, etcd_prefix )
		@output_base = output_base
		@etcd_prefix = etcd_prefix
	end

	def etcd_key_prefix
		@etcd_prefix
	end

	def generate_upstream( host, config, upstreams )
		result = translate_host( config, upstreams, @template )

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

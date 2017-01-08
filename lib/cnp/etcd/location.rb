########################################
#
#
# EtcD V2 Location
########################################

module CNP
	module EtcD
		module V2
			class LocationSettings
				def initialize( key, etcdctl )
					@base = key
					@etcd = etcdctl
				end

				def request_body_size
					key = @base + "/request_body_size"
					return nil unless @etcd.exists? key
					@etcd.get( key ).value
				end

				def request_body_size=( size )
					key = @base + "/request_body_size"
					@etcd.set( key, value: size.to_json )
				end

				def path
					key = @base + "/path"
					@etcd.get( key ).value
				end

				def path=( where )
					key = @base + "/path"
					@etcd.set( key, value: where )
				end
			end
		end
	end
end

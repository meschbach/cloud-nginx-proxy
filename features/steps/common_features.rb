module CommonFeatures
	include Spinach::DSL

  step 'the configuration is activated' do
		@upstream_server = "upstream.invalid"
		upstreams = [ @upstream_server ]
		@host_config = CNP.translate_host( @descriptor, upstreams )
  end

  step 'the hostname and port are correct' do
		@host_config.should include( "listen *:80;" )
		@host_config.should include( "server_name #{@host_name};" )
  end

  step 'the upstreams are generated' do
		@host_config.should include( "upstream #{@upstream_name} {" )
		@host_config.should include( "server #{@upstream_server}" )
  end

  step 'all traffic is passed to the backends' do
		@host_config.should include( "location / {" )
		@host_config.should include( "proxy_pass" )
  end
end


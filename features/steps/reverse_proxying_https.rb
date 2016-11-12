Given 'I have an HTTPS site configured' do
	@key_file = '/x509/private'
	@certificate_file = '/x509/public'

	@host_name = 'example.invalid'
	@upstream_name = 'https_upstreams'
	@descriptor = OpenStruct.new({
		"name" => @upstream_name,
		"host" => @host_name,
		"https" => {
			"key" => @key_file,
			"certificate" => @certificate_file
		}
	})
end

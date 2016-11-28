Feature: ETCD v2 Coordination Layer
	In order to improve configurability of nginx and discoverability of applications
	As an operator
	I would like to use a more expressive key value store

	Scenario: I would like simple out of the box application configuration
		Given I have configured EtcD-V2 for root /test/v2
		When I register a simple site and upstream using EtcD-V2
		Then the configuration should activate with the default connectors

	Scenario: I would like to use additional connectors
		Given I have a register EtcD-V2 storage in the system
		And the host name is 'connectors.v2.etcd.cnp.invalid'
		And the upstream is 'connector-test'
		When I register the EtcD-V2 connector 'public' for HTTP with ports 80 and 8080
		And register the upstream 'connector-test' with 'http://localhost:9292' named 'port9292'
		And reigster the host with connector 'public' and upstream 'connector-test'
		And ask the system to generate the configuration for the site
		Then the host name is correct
		And listening on port 80
		And listening on port 8080

	Scenario: I would like to host an HTTPS site
		Given I have a register EtcD-V2 storage in the system
		When I register a connector 'test-https' for TLS on port 443
		And upstream 'test-https' for upstream 'localhost:9999'
		And I register host 'https.etcd2.cnp.invalid' to use connector 'test-https' and upstream 'test-https'
		And I register host 'https.etcd2.cnp.invalid' to use certificate '/src/https/example.cert' and key '/src/https/example.key'
		And ask the system to generate the configuration for the site
		Then listening on port 443
		And is using the certificate '/src/https/example.cert'
		And is using the key '/src/https/example.key'

Feature: ETCD v2 Coordination Layer
	In order to improve configurability of nginx and discoverability of applications
	As an operator
	I would like to use a more expressive key value store

	Scenario: I would like simple out of the box application configuration
		Given I have configured EtcD-V2 for root /test/v2
		When I register a simple site and upstream using EtcD-V2
		Then the configuration should activate with the default connectors

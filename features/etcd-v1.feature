Feature: ETCD v1 Coordination Layer
	In order for applications to be configurable and discoverable
	As an operator
	I would like to use th original EtcD configuration layer

	Scenario: I regsiter a host the configuration should be available
		Given I have configured EtcD for root /test/v1/registration
		When I register a simple host configuration with EtcD
		Then the host is visible to the application with EtcD

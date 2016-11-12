Feature: Reverse Proxying HTTPS
	In order to HTTPS sites
	As an operator
	I would like applications to automatically be load balanced on start

	Scenario: Deploys to the correct hostname and port
		Given I have an HTTPS site configured
		When the configuration is activated
		Then the hostname and port are correct
		And the upstreams are generated
		And all traffic is passed to the backends

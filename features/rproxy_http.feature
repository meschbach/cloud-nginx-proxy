Feature: Reverse Proxying HTTP
	In order to load balance pure HTTP sites
	As an operator
	I would like applications to automatically be load balanced on start

	Scenario: Deploys to the correct hostname and port
		Given I have an HTTP site configured
		When the configuration is activated
		Then listening on port 80
		And the host name is correct
		And the upstreams are generated
		And all traffic is passed to the backends

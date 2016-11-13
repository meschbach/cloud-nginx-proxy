Feature: Reverse Proxying HTTPS
	In order to HTTPS sites
	As an operator
	I would like applications to automatically be load balanced on start

	Scenario: Deploys to the correct hostname and port
		Given I have an HTTPS site configured
		When the configuration is activated
		Then the hostname is correct
		And listening on port 443
		And not listening on port 80
		And the upstreams are generated
		And all traffic is passed to the backends

	Scenario: Deploys a given upload limit override
		Given I have an HTTPS site configured
		And allows 256M to be uploaded to '/example-upload'
		When the configuration is activated
		Then the location '/example-upload' passes the proxy
		And the location '/example-upload' allows for 256M
		And the location '/example-upload' imports the proxy configuration

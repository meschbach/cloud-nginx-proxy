Feature: HTTP Connector Management
  To support client separation on multiple ports
  As an operator
	I would like to specify listening configurations

  Scenario: Defaults to listening on port 80 for HTTP
		Given I have an HTTP site configured
		When the configuration is activated
		Then listening on port 80

  Scenario: Allows override for default port
		Given I have an HTTP site configured
		And the HTTP site is configured to listen on port 8080
		When the configuration is activated
		Then listening on port 8080
		And not listening on port 80

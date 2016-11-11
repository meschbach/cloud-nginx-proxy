Feature: Reverse Proxying HTTP
	In order to load balance pure HTTP sites
	As an operator
	I would like applications to automatically be load balanced on start

	Scenario: Single Backend
		Given I have an HTTP site configured
		When the configuration is activated
		Then the HTTP nginx configuration is correctly generated

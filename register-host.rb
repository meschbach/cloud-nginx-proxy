#!/bin/bash -e ruby

require 'rubygems'
require 'bundler/setup'
require 'json'

require File.join( File.dirname( __FILE__ ), 'lib', 'cnp', 'etcd' )

#
# CLI
#
require 'trollop'
opts = Trollop::options do
	opt :etcd_prefix, "etcd load balancer prefix", :default => "/lb"
	opt :config_file, "Configuration file to be loaded", :type => :string, :required => true
end

#
# Extract Parameters
#
etcd_prefix = opts[:etcd_prefix]
config_contents = File.read( opts[:config_file] )

#
# Do it
#
storage = CNP::EtcD::V1.new( etcd_prefix )
storage.register_host( config_contents )

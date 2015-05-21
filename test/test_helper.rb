$:.unshift File.join(File.dirname(__FILE__),'..','lib')
#http://net.tutsplus.com/tutorials/ruby/ruby-for-newbies-testing-with-rspec/
require_relative '../lib/zenoss'
require 'vcr'


ZENOSS_URL = ENV['zenoss_client_url'] || "http://localhost:8080/zport/dmd"
ZENOSS_USER = ENV['zenoss_client_username'] || "admin"
ZENOSS_PASSWORD = ENV['zenoss_client_password'] || "zenoss"

TEST_DEVICE_NAME = "UnitTestDevice"

# VCR
VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :webmock
end

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
#http://net.tutsplus.com/tutorials/ruby/ruby-for-newbies-testing-with-rspec/
require_relative '../lib/zenoss'
require 'vcr'
require 'webmock'

ZENOSS_URL = ENV['zenoss_client_url'] || "http://localhost:8080/zport/dmd"
ZENOSS_USER = ENV['zenoss_client_username'] || "admin"
ZENOSS_PASSWORD = ENV['zenoss_client_password'] || "zenoss"

TEST_DEVICE_NAME = "UnitTestDevice"

ZENOSS_VERSION = ENV['zenoss_version'] || '4.2.5'

include WebMock::API

# VCR
WebMock.enable!
VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :webmock

  config.filter_sensitive_data('admin') { ZENOSS_USER }
  config.filter_sensitive_data('http://localhost:8080/zport/dmd') { ZENOSS_URL }
  config.filter_sensitive_data('zenoss') { ZENOSS_PASSWORD }

  config.before_record do |interaction, cassette|
    if cassette.name == '6.2.1_initial connection'
      interaction.request.body = '__ac_name=admin&__ac_password=zenoss'\
                                 '&submitted=true&came_from=https%3A%2F'\
                                 '%2Fhttp:://localhost:8080/zport/dmd'\
                                 '%2Fzport%2Fdmd'
    end
  end
end


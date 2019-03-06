require_relative './test_helper'
require 'minitest/autorun'

describe Zenoss::Model::Device do
  it 'raises error on #set_info when version is less than 6' do
    opts = {}
    opts[:version] = '4.2.5'
    opts[:no_sign_in] = true
    connection = Zenoss::Connection.new('http://localhost', 'admin', 'zenoss', opts)
    zhash = {
      productionState: 400,
      priority: 3,
      uid: '/zport/dmd/Devices/Server/devices/UnitTestDevice',
      name: 'UnitTestDevice'
    }

    dev = Zenoss::Model::Device.new(connection, zhash)
    options = {}
    options[:productionState] = -1
    exception = assert_raises Zenoss::ZenossError do
      dev.set_info(options)
    end
    assert_equal('setInfo method on DeviceRouter is only allowed for version 6 and above', exception.message)
  end
end

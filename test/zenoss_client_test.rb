require_relative './test_helper'
require 'minitest/autorun'
require 'logger'

LOG = Logger.new(STDOUT)
LOG.level = Logger::INFO

describe Zenoss do
  # Simulate some "before all" type of setup
  # https://github.com/seattlerb/minitest/issues/61#issuecomment-4581115
  def self.zen
    VCR.use_cassette "#{ZENOSS_VERSION}_initial connection", :match_requests_on => [:method, :path, :query]  do
      @zen ||= begin
        opts = {}
        opts[:version] = ZENOSS_VERSION
        connection = Zenoss.connect ZENOSS_URL, ZENOSS_USER, ZENOSS_PASSWORD, opts
        # We Need to Create A Device for testing
        # We do this here, so we can re-use the same device over and over
        # Without needing to create a new one per test
        LOG.info('Creating a Fresh Device For Testing')
        new_device_rsp = connection.json_request(
          'DeviceRouter', 'addDevice',
          [{:deviceName => TEST_DEVICE_NAME, :deviceClass => '/Devices/Server'}]
        )

        # Now we need to wait until the device is present before we proceed.
        # Once we issue the create command, it takes
        if new_device_rsp.key?('success') && new_device_rsp['success'] == true
          # Our job was accepted
          retries = 20
          retry_delay = 15  # seconds
          found_device = false
          LOG.info('Waiting for the newly created device to be available. ' \
                   'This might take a minute or two')
          while found_device == false
            if retries > 0
              # This will return an Array, so we wait until the array has
              # something, or we give up after a while
              devs = connection.find_devices_by_name(TEST_DEVICE_NAME)
              if devs.empty?
                retries -= 1
                LOG.info("#{TEST_DEVICE_NAME} not available yet")
                sleep(retry_delay) if VCR.current_cassette.recording?
              else
                found_device = true
                LOG.info("#{TEST_DEVICE_NAME} is available. Proceeding with " \
                  'testing')
              end
            else
              fail ZenossError, 'Unable to Create A New Device For Unit Tests'
            end
          end
        else
          # We failed to create a new device....
        end
        # Return the connection object
        connection
      end
    end
  end

  def gen_cassette_name
    n = "#{ZENOSS_VERSION}_#{name}"
    # name method is not available on ruby 1.9
    rescue NoMethodError, NameError
      fallback_method = [:__name__, :__NAME__].find { |m| self.respond_to? m }
      n = "#{ZENOSS_VERSION}_#{send(fallback_method)}"
    n.gsub!('.', '_')
    n
  end

  before do
    WebMock.allow_net_connect!
    VCR.insert_cassette gen_cassette_name, :match_requests_on => [:method, :path, :query], :allow_playback_repeats => true
    @zen = self.class.zen
    @dev = @zen.find_devices_by_name(TEST_DEVICE_NAME).first
  end

  after do
    VCR.eject_cassette gen_cassette_name
    WebMock.disable_net_connect!
  end

  it 'returns an Array of devices when searched by name' do
    x = @zen.find_devices_by_name(TEST_DEVICE_NAME)
    x.must_be_kind_of Array
    x.first.must_be_kind_of Zenoss::Model::Device
  end

  it 'returns device uptime when asked' do
    @dev.sys_uptime.wont_be_nil
    @dev.sys_uptime.wont_be_empty
  end

  it 'returns an Array of events for a device' do
    # There could be 0 or more, events so an empty Array is OK
    @dev.get_events.must_be_kind_of Array
  end

  it 'returns an Array of historical events for a device' do
    # There could be 0 or more, events so an empty Array is OK
    @dev.get_event_history.must_be_kind_of Array
  end

  it 'returns info for a device in the form of a Hash' do
    @dev.get_info.wont_be_nil
    @dev.get_info.wont_be_empty
    @dev.get_info.must_be_kind_of Hash
  end

  it 'returns an Array of events for all devices' do
    events = @zen.query_events
    events.must_be_kind_of Array
    events.first.must_be_kind_of Zenoss::Events::ZEvent
  end

  it 'fetches the report tree' do
    report_tree = @zen.get_report_tree
    report_tree.must_be_kind_of Array
    report_tree.first.must_be_kind_of Hash
    report_tree.wont_be_empty
  end

  it 'fetches available report types and returns a Hash' do
    report_types = @zen.get_report_types
    report_types.must_be_kind_of Hash
    report_types.wont_be_empty
    report_types.key?('reportTypes').must_equal true
  end

  it 'renames the device' do
    TEMPORARY_DEVICE_NAME = 'unit_test_temporary_device_name'
    begin
      @dev.rename_device(TEMPORARY_DEVICE_NAME)
      renamed_devices = @zen.find_devices_by_name(TEMPORARY_DEVICE_NAME)
      renamed_devices.wont_be_empty
      renamed_device = renamed_devices.first
      renamed_device.name.must_equal TEMPORARY_DEVICE_NAME
    ensure
      renamed_device.rename_device(TEST_DEVICE_NAME)
    end
  end

  if ZENOSS_VERSION > '6'
    it 'sets info for a device' do
      opts = {}
      opts[:uid] = @dev.uid
      opts[:productionState] = -1
      set_info = @zen.set_info(opts)
      set_info.must_be_kind_of Hash
      set_info.wont_be_empty
      set_info['success'].must_equal true
    end

    it 'sets info for a device on a device object' do
      opts = {}
      opts[:productionState] = -1
      set_info = @dev.set_info(opts)
      set_info.must_be_kind_of Hash
      set_info.wont_be_empty
      set_info['success'].must_equal true
    end
  end
end

describe Zenoss do

  before do
    VCR.turn_off!
  end

  after do
    VCR.turn_on!
  end

  stub_request(:post, 'http://localhost/zport/acl_users/cookieAuthHelper/login')
    .with(
      body: {
        '__ac_name' => 'admin',
        '__ac_password' => 'zenoss',
        'came_from' => 'http://localhost/zport/dmd',
        'submitted' => 'true'
      },
      headers: {
        'Accept' => '*/*',
        'Content-Type' => 'application/x-www-form-urlencoded'
      })
    .to_return(status: 200,
               body: '',
               headers: {})

  stub_request(:post, 'http://localhost/zport/dmd/device_router')
    .with(
      body: "[{\"action\":\"DeviceRouter\",\"method\":\"getDevices\","\
            "\"data\":[{\"uid\":\"/zport/dmd/Devices\","\
            "\"params\":{\"name\":\"UnitTestDevice\"}}],\"type\":\"rpc\","\
            "\"tid\":1}]",
      headers: {
        'Accept'=>'*/*',
        'Content-Type'=>'application/json; charset=utf-8'
      })
    .to_return(status: 200,
               body: '{"uuid": "8c37791a-f4c7-4dec-b3dd-37b4f2aee84b", '\
                     '"action": "DeviceRouter", "result": {"totalCount": 1, '\
                     '"hash": "1", "success": true, "devices": '\
                     '[{"ipAddressString": null, "serialNumber": "", '\
                     '"pythonClass": "Products.ZenModel.Device", '\
                     '"hwManufacturer": null, "collector": "localhost", '\
                     '"osModel": null, "productionState": 400, "systems": [], '\
                     '"priority": 3, "hwModel": null, "tagNumber": "", '\
                     '"osManufacturer": null, "location": null, "groups": [], '\
                     '"uid": "/zport/dmd/Devices/Server/devices/UnitTestDevice"'\
                     ', "ipAddress": null, "events": {"info": '\
                     '{"count": 0, "acknowledged_count": 0}, "clear": '\
                     '{"count": 0, "acknowledged_count": 0}, "warning": '\
                     '{"count": 0, "acknowledged_count": 0}, "critical": '\
                     '{"count": 0, "acknowledged_count": 0}, "error": '\
                     '{"count": 0, "acknowledged_count": 0}, "debug": '\
                     '{"count": 0, "acknowledged_count": 0}}, "name": '\
                     '"UnitTestDevice"}]}, "tid": 1, "type": "rpc", '\
                     '"method": "getDevices"}',
               headers: {})

  it 'raises error on #set_info when version is less than 6' do
    opts = {}
    opts[:version] = '4.2.5'
    connection = Zenoss.connect('http://localhost', 'admin', 'zenoss', opts)
    dev = connection.find_devices_by_name(TEST_DEVICE_NAME).first
    options = {}
    options[:productionState] = -1
    exception = assert_raises Zenoss::ZenossError do
      dev.set_info(options)
    end
    assert_equal('setInfo method on DeviceRouter is only allowed for version 6 and above', exception.message)
  end
end

describe Zenoss::Events::Event do
  it 'initializes an object with times as strings' do
    @zenoss = Zenoss
    firstTime = Time.new(2018, 10, 3, 1, 0, 0)
    lastTime = Time.new(2018, 10, 3, 3, 0, 0)
    zhash = {
      firstTime: firstTime.to_s,
      lastTime: lastTime.to_s
    }
    event = Zenoss::Events::Event.new(@zenoss, zhash)
    event.must_be_kind_of Zenoss::Events::Event
    event.firstTime.must_be_kind_of Time
    event.lastTime.must_be_kind_of Time
  end

  it 'intializes an object with times as unix time' do
    @zenoss = Zenoss
    firstTime = Time.new(2018, 10, 3, 2, 0, 0)
    lastTime = Time.new(2018, 10, 3, 5, 0, 0)
    zhash = {
      firstTime: firstTime.to_f,
      lastTime: lastTime.to_f
    }
    event = Zenoss::Events::Event.new(@zenoss, zhash)
    event.must_be_kind_of Zenoss::Events::Event
    event.firstTime.class.must_equal Time
    event.firstTime.must_be_kind_of Time
    event.lastTime.must_be_kind_of Time
  end

  it 'intializes an object with times set to nil' do
    @zenoss = Zenoss
    zhash = {
      firstTime: nil,
      lastTime: nil
    }
    event = Zenoss::Events::Event.new(@zenoss, zhash)
    event.must_be_kind_of Zenoss::Events::Event
    assert_nil event.firstTime
    assert_nil event.lastTime
  end

  it 'intializes an object with times set to false' do
    @zenoss = Zenoss
    zhash = {
      firstTime: false,
      lastTime: false
    }
    event = Zenoss::Events::Event.new(@zenoss, zhash)
    event.must_be_kind_of Zenoss::Events::Event
    event.firstTime.must_equal false
    event.lastTime.must_equal false
  end
end

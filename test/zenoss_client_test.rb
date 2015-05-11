require_relative './test_helper'
require 'minitest/spec'
require 'minitest/autorun'
require 'logger'

LOG = Logger.new(STDOUT)
LOG.level = Logger::INFO


describe Zenoss do
  #Simulate some "before all" type of setup
  #https://github.com/seattlerb/minitest/issues/61#issuecomment-4581115
  def self.zen
    @zen ||= begin
      connection = Zenoss.connect ZENOSS_URL, ZENOSS_USER, ZENOSS_PASSWORD
      #We Need to Create A Device for testing
      #We do this here, so we can re-use the same device over and over
      #Without needing to create a new one per test
      LOG.info("Creating a Fresh Device For Testing")
      new_device_rsp = connection.json_request(
        'DeviceRouter', 'addDevice', 
          [{:deviceName => TEST_DEVICE_NAME, :deviceClass => '/Devices/Server'}]
      )

      #Now we need to wait until the device is present before we proceed. 
      #Once we issue the create command, it takes
      if new_device_rsp.has_key?("success") && new_device_rsp['success'] == true
        #Our job was accepted
        retries = 20  
        retry_delay = 15  #seconds
        found_device = false
        LOG.info("Waiting for the newly created device to be available. " +
          "This might take a minute or two")
        while found_device == false
          if retries > 0
            #This will return an Array, so we wait until the array has
            #something, or we give up after a while
            devs = connection.find_devices_by_name(TEST_DEVICE_NAME)
            if devs.empty?
              retries -= 1
              LOG.info("#{TEST_DEVICE_NAME} not available yet")
              sleep(retry_delay)
            else
              found_device = true
              LOG.info("#{TEST_DEVICE_NAME} is available. Proceeding with " +
                "testing")
            end
          else
            raise ZenossError, "Unable to Create A New Device For Unit Tests"
          end
        end
      else
        #We failed to create a new device....
      end
      #Return the connection object
      connection
    end    
  end
  
  before do
    @zen = self.class.zen
    @dev = @zen.find_devices_by_name(TEST_DEVICE_NAME).first
  end

    
  it "returns an Array of devices when searched by name" do
    x = @zen.find_devices_by_name(TEST_DEVICE_NAME)
    x.must_be_kind_of Array
    x.first.must_be_kind_of Zenoss::Model::Device
  end
  
  it "returns device uptime when asked" do
    @dev.sys_uptime.wont_be_nil
    @dev.sys_uptime.wont_be_empty
  end
  
  it "returns an Array of events for a device" do
    #There could be 0 or more, events so an empty Array is OK
    @dev.get_events.must_be_kind_of Array
  end
  
  it "returns an Array of historical events for a device" do
    #There could be 0 or more, events so an empty Array is OK
    @dev.get_event_history.must_be_kind_of Array
  end
  
  it "returns info for a device in the form of a Hash" do
    @dev.get_info().wont_be_nil
    @dev.get_info().wont_be_empty
    @dev.get_info().must_be_kind_of Hash
  end
  
  it "returns an Array of events for all devices" do
    events = @zen.query_events
    events.must_be_kind_of Array
    events.first.must_be_kind_of Zenoss::Events::ZEvent
  end

  it "fetches the report tree" do
    report_tree = @zen.get_report_tree
    report_tree.must_be_kind_of Array
    report_tree.first.must_be_kind_of Hash
    report_tree.wont_be_empty
  end
  
  it "fetches available report types and returns a Hash" do
    report_types = @zen.get_report_types
    report_types.must_be_kind_of Hash
    report_types.wont_be_empty
    report_types.has_key?("reportTypes").must_equal true
  end
  
end



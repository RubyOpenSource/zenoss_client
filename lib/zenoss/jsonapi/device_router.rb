#############################################################################
# Copyright © 2010 Dan Wanek <dwanek@nd.gov>
#
#
# This file is part of zenoss_client.
#
# zenoss_client is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
#
# zenoss_client is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with zenoss_client.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
module Zenoss
  module JSONAPI
    module DeviceRouter

      # @param [String] uid The organizer path to fetch devices from. This can be a
      #   devclass, group, system, or location.
      # @param [Hash] opts optional arguments to pass to getDevices
      # @option opts [Fixnum] :start Offset to return the results from; used in pagination (default: 0)
      # @option opts [Fixnum] :limit Number of items to return; used in pagination (default: 50)
      # @option opts [String] :sort_key Key on which to sort the return results (default: 'name')
      # @option opts [String] :sort_ord Sort order; can be either 'ASC' or 'DESC' (default: 'ASC')
      # @option opts [Hash] :params Key-value pair of filters for this search. Can be one of the following: (default: {})
      # @option :params [String] :name
      # @option :params [String] :ipAddress
      # @option :params [String] :deviceClass the device class not including the 'Devices' part, for instance '/Server/Linux'
      # @option :params [String] :productionState
      def get_devices(uid = '/zport/dmd/Devices', opts = {})
        uid = "/zport/dmd#{uid}" unless uid.start_with?('/zport/dmd')
        data = { :uid => uid }
        data[:start]  = opts[:start] if opts.has_key? :start
        data[:limit]  = opts[:limit] if opts.has_key? :limit
        data[:sort]   = opts[:sort_key] if opts.has_key? :sort_key
        data[:dir]    = opts[:sort_ord] if opts.has_key? :sort_ord
        data[:params] = opts[:params] || {}
        resp = json_request('DeviceRouter', 'getDevices', [data])

        devs = []
        resp['devices'] && resp['devices'].each do |dev|
          devs << Model::Device.new(self, dev)
        end
        devs
      end

      def get_templates(device_id)
        resp = json_request('DeviceRouter', 'getTemplates', [{:id => device_id}])
      end

      def get_info(device_id, keys = nil)
        data = {}
        data[:uid]  = device_id
        data[:keys] = keys if keys
        resp = json_request('DeviceRouter', 'getInfo', [data])
      end

      # =============== Non-API Helper methods ===============

      # This method will allow you to search for devices by name. If you put a partial name
      #   it will return all matching entries. For example:
      #   find_devices_by_name 'mydev' will return all devices that start with mydev
      # @param [String] name the name of the device to search for
      # @param [Hash] opts options to help limit device search
      # @option opts [String] :deviceClass the device class to limit the search to
      # @option opts [String] :productionState the production state to limit the search to
      # @return [Array] an array of devices found or an empty array if nothing is matched
      def find_devices_by_name(name, opts={})
        opts[:name] = name
        get_devices('/zport/dmd/Devices', :params => opts)
      end

      # This method will find a device for the given IP Address or all matching devices
      #   given a partial IP.
      # @param [String] ip the ip address of the device to search for
      # @param [Hash] opts options to help limit device search
      # @option opts [String] :deviceClass the device class to limit the search to
      # @option opts [String] :productionState the production state to limit the search to
      # @return [Array] an array of devices found or an empty array if nothing is matched
      def find_devices_by_ip(ip, opts={})
        opts[:ipAddress] = ip
        get_devices('/zport/dmd/Devices', :params => opts)
      end

    end # DeviceRouter
  end # JSONAPI
end # Zenoss

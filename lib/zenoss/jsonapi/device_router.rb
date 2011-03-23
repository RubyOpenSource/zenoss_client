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

      def get_devices(device_class = '/zport/dmd/Devices')
        resp = json_request('DeviceRouter', 'getDevices', [{:uid => device_class}])

        devs = []
        resp['devices'].each do |dev|
          devs << Model::Device.new(self, dev)
        end
        devs
      end

      def get_templates(device_id)
        resp = json_request('DeviceRouter', 'getTemplates', [{:id => device_id}])
      end

    end # DeviceRouter
  end # JSON
end # Zenoss

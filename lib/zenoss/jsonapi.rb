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
    ROUTERS = {
      'MessagingRouter' => 'messaging',
      'EventsRouter'    => 'evconsole',
      'ProcessRouter'   => 'process',
      'ServiceRouter'   => 'service',
      'DeviceRouter'    => 'device',
      'NetworkRouter'   => 'network',
      'TemplateRouter'  => 'template',
      'DetailNavRouter' => 'detailnav',
      'ReportRouter'    => 'report',
      'MibRouter'       => 'mib',
      'ZenPackRouter'   => 'zenpack',
    }

    def json_request(router, method, data={})
      raise ZenossError, "Router (#{router}) not found" unless ROUTERS.has_key?(router)

      req_url = "#{@zenoss_uri}/zport/dmd/#{ROUTERS[router]}_router"
      req_headers = {'Content-type' => 'application/json; charset=utf-8'}
      req_body = [{
        :action => router,
        :method => method,
        :data   => data,
        :type   => 'rpc',
        :tid    => @request_number,
      }].to_json

      @request_number += 1

      resp = @httpcli.post req_url, req_body, req_headers
      parse_json(resp)
    end

    private

    # Check the HTTP and JSON response for errors and return JSON response
    def parse_json(resp)
      begin
        if(resp.status != 200)
          raise ZenossError, "Bad HTTP Response #{resp.status}: Cound not make JSON call"
        end

        json = JSON.load(resp.http_body.content)
        # Handle the situation where the 'result' key in the JSON response does not
        # point to a hash, but instead is nil.
        # This has been seen in the wild on an installation of Zenoss 4.2.5
        if(json['result'].nil?
          raise ZenossError, "JSON request '#{json['method']}' on '#{json['action']}' returned malformed data"
        end

        # Check for JSON success. There are some exceptions where this doesn't make sense:
        #   1. Sometimes the 'success' key does not exist like in EventsRouter#query
        #   2. When json['result'] is not a Hash like a return from ReportRouter#get_tree
        if(json['result'].is_a?(Hash) && json['result'].has_key?('success') && !json['result']['success'])
          raise ZenossError, "JSON request '#{json['method']}' on '#{json['action']}' was unsuccessful"
        end

        json['result']
      rescue JSON::ParserError => e
        raise ZenossError, "Invalid JSON response: #{e.message}"
      end
    end

  end
end

require 'zenoss/jsonapi/device_router'
require 'zenoss/jsonapi/events_router'
require 'zenoss/jsonapi/report_router'

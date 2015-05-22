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
require 'zenoss/jsonapi'
require 'zenoss/restapi'

module Zenoss

  # This class represents a connection into a Zenoss server.
  class Connection
    include Zenoss
    include Zenoss::JSONAPI
    include Zenoss::JSONAPI::DeviceRouter
    include Zenoss::JSONAPI::EventsRouter
    include Zenoss::JSONAPI::ReportRouter
    include Zenoss::RESTAPI

    def initialize(url, user, pass, opts = {}, &block)
      @zenoss_uri = (url.is_a?(URI) ? url : URI.parse(url))
      @request_number = 1
      @httpcli = HTTPClient.new
      @httpcli.receive_timeout = 360  # six minutes should be more that sufficient
      yield(@httpcli) if block_given?
      sign_in(user, pass) unless opts[:no_sign_in]
    end

    private

    # Sign-in to this Zenoss instance.
    def sign_in(user,pass)
      login_parms = {
        :__ac_name     => user,
        :__ac_password => pass,
        :submitted     => true,
        :came_from     => "#{@zenoss_uri}/zport/dmd",
      }
      login_path = "#{@zenoss_uri}/zport/acl_users/cookieAuthHelper/login"
      resp = @httpcli.post login_path, login_parms
      if(resp.status == 302)
        login_path = resp.header['Location'].first
        login_path = "#{@zenoss_uri}/#{login_path}"
        resp = @httpcli.post login_path, login_parms 
        raise ZenossError, "(HTTP Response #{resp.status}) Could not authenticate to #{@zenoss_uri}" unless resp.status == 200
      end
      true
    end

  end # Connection
end # Zenoss

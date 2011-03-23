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

module Zenoss

  # This class represents a connection into a Zenoss server.
  class Connection
    include Zenoss
    include Zenoss::JSONAPI
    include Zenoss::JSONAPI::DeviceRouter
    include Zenoss::JSONAPI::EventsRouter

    def initialize(url, user, pass)
      @zenoss_uri = (url.is_a?(URI) ? url : URI.parse(url))
      @zenoss_uri.path << '/' unless(@zenoss_uri.path.end_with? '/')
      @request_number = 1
      @httpcli = HTTPClient.new
      sign_in(user,pass)
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
        resp = @httpcli.post login_path, login_parms 
        raise ZenossError, "(HTTP Response #{resp.status}) Could not authenticate to #{@zenoss_uri}" unless resp.status == 200
      end
      true
    end


    #---------- LEGACY REST METHODS ---------- #


    # Prepend the appropriate path and call the REST method on the URL set with Zenoss#uri
    #
    # @param [String] req_path the request path of the REST method
    # @return [String] the response body of the REST call
    def rest(req_path)
      Net::HTTP.start(Zenoss::BASE_URI.host,Zenoss::BASE_URI.port) {|http|
        req = Net::HTTP::Get.new("#{BASE_URI.path}#{req_path}")
        puts "Request: #{BASE_URI.path}#{req_path}"
        req.basic_auth USER, PASS if USER
        response = http.request(req)
        response.body.chomp! unless response.body.nil?
        return(response.body)
      }
    end

    # Call a custom Zope method to work around some issues of unsupported or bad behaving
    # REST methods.
    # @see http://gist.github.com/343627 for more info.
    #
    # @param [String] req_path the request path of the REST method ( as if it wasn't misbehaving )
    #   @example req_path
    #     getRRDValues?dsnames=['ProcessorTotalUserTime_ProcessorTotalUserTime','MemoryPagesOutputSec_MemoryPagesOutputSec']
    # @param [String] callback_func the name of the function to be called on the returned object before giving it back to Ruby
    # @param [String] callback_attr the name of the attribute to fetch on the returned object before giving it back to Ruby
    # @return [String] the response body of the REST call
    def custom_rest(req_path,callback_func = nil, callback_attr=nil)
      meth,args = req_path.split('?')
      meth = "callZenossMethod?methodName=#{meth}"
      unless args.nil?
        meth << '&args=['
        # Remove the named parameters because we can't dynamically call named parameters in Python.
        # This method uses positional parameters via the passed Array (Python List).
        args.split('&').inject(nil) do |delim,arg|
          arg.gsub!(/'/, "'''") # This may cause problems if the passed argument is already triple quoted.
          meth << "#{delim}#{arg.split('=').last}"
          delim = '===' if delim.nil?
        end
        meth << ']'
      end
      meth << "&filterFunc=#{callback_func}" unless callback_func.nil?
      meth << "&filterAttr=#{callback_attr}" unless callback_attr.nil?
      puts "METHOD: #{meth}"
      rest(meth)
    end

  end # Connection
end # Zenoss

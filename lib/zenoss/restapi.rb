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
  module RESTAPI

    # Prepend the appropriate path and call the REST method on the URL set with Zenoss#uri
    #
    # @param [String] req_path the request path of the REST method
    # @return [String] the response body of the REST call
    def rest(req_path)
      resp = @httpcli.get "#{@zenoss_uri}#{req_path}"
      parse_rest(resp)
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
    def custom_rest(dev_path, req_path, callback_func = nil, callback_attr=nil)
      puts "ORIGINAL: #{req_path}" if $DEBUG
      meth,args = req_path.split('?')
      meth = "callZenossMethod?methodName=#{meth}"
      unless args.nil?
        meth << '&args=['
        # Remove the named parameters because we can't dynamically call named parameters in Python.
        # This method uses positional parameters via the passed Array (Python List).
        meth << args.split('&').inject('') do |parms,arg|
          arg.gsub!(/'/, "'''") # This may cause problems if the passed argument is already triple quoted.
          parms << '===' unless parms.empty?
          parms << arg.split('=').last
        end
        meth << ']'
      end
      meth << "&filterFunc=#{callback_func}" unless callback_func.nil?
      meth << "&filterAttr=#{callback_attr}" unless callback_attr.nil?
      meth = "#{URI.encode(dev_path)}/#{URI.encode(meth)}"
      puts "METHOD: #{meth}" if $DEBUG
      rest(meth)
    end


    private

    # Check the HTTP and REST response for errors and return appropriate response
    def parse_rest(resp)
      begin
        if(resp.status >= 300)
          raise ZenossError, "Bad HTTP Response #{resp.status}: Cound not make REST call"
        end

        resp.http_body.content
      end
    end

  end # RESTAPI
end # Zenoss

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
require 'rubygems'
require 'date'
require 'tzinfo'
require 'uri'
require 'ostruct'
require 'httpclient'
require 'json'

# An extension to IPAddr for address conversion
require 'ext/ipaddr'

module Zenoss

  # initialize a connection to a Zenoss server. This is the same as doing
  #   Zenoss::Connection.new(server,user,pass)
  def Zenoss.connect(server, user, pass, opts = {}, &block)
    Connection.new(server, user, pass, opts, &block)
  end

  # Some of the REST methods return Strings that are formated like a Python list.
  # This method turns that String into a Ruby Array.
  # If the list parameter is nil the return value is also nil.
  #
  # @param [String] list a Python formatted list
  # @return [Array,nil] a bonafide Ruby Array
  def plist_to_array(list)
    return nil if list.nil?
    list = sanitize_str(list)
    (list.gsub /[\[\]]/,'').split /,\s+/
  end

  # Some of the REST methods return Strings that are formated like a Python list.
  # This method turns that String into a Ruby Array.
  # If the list parameter is nil the return value is also nil.
  # WARNING: This will soon supersede #plist_to_array
  #
  # @param [String, Array] list a Python formatted list or Array of chars
  # @param [Boolean] first a flag that tells whether this is a recursive call or not
  # @return [Array,nil] a bonafide Ruby Array
  def parse_array(list, first = true)
    return nil if list.nil?
    open = false
    narray = []
    list = list.chars.to_a unless list.is_a?(Array)
    while( token = list.shift )
      case token
      when /[\[\(]/
        open = true
        if(first)
          narray = parse_array(list, false)
        else
          narray << parse_array(list, false)
        end
      when /[\]\)]/ 
        open = false
        return narray
      when /["']/
        qtype = token
        tokenstr = ''
        while( (token = list.shift) !~ /#{qtype}/ )
          tokenstr << token
        end
        narray << tokenstr
      when /\d/
        while( list[0] =~ /\d/ )
          token << list.shift
        end
        narray << token.to_i
      end
    end

    narray
  end

  # Converts a String formatted like a Python Dictionary to a Ruby Hash.
  #
  # @param [String] dict a Python dictionary
  # @return [Hash,nil] a Ruby Hash
  def pdict_to_hash(dict)
    return nil if dict.nil?
    dict = sanitize_str(dict)
    dict = dict.sub(/^\{(.*)\}$/,'\1').split(/[,:]/).map do |str|
      str.strip
    end
    Hash[*dict]
  end

  # Converts a String in Python's DateTime format to Ruby's DateTime format
  # If the pdt parameter is nil the return value is also nil.
  #
  # @param [String] pdt a String formatted in Python's DateTime format
  # @return [DateTime] a bonafide Ruby DateTime object
  def pdatetime_to_datetime(pdt)
    return nil if pdt.nil?
    pdt = pdt.split(/\s+/)
    tz = TZInfo::Timezone.get(pdt.last)
    DateTime.strptime("#{pdt[0]} #{pdt[1]} #{tz.current_period.abbreviation.to_s}", '%Y/%m/%d %H:%M:%S.%N %Z')
  end

  # This takes an array of two element Python tuples and turns it into a
  # Ruby hash.
  #
  # @param [Array] tuple_array an Array of Strings formatted like two-element Python tuples
  # @return [Hash] a Ruby hash of key-value pairs taken from the tuple argument
  def ptuples_to_hash(tuple_array)
    return nil if tuple_array.empty?
    thash = {}
    tuple_array.each do |tuple|
      str = sanitize_str(tuple.strip)
      k, *v = str.slice!(1..-2).split(/\s*,\s*/)
      if(v.length <= 1)
        thash[k] = v.first
      else
        v[0]  = v[0].slice(1..-1)
        v[-1] = v[-1].slice(0..-2)
        thash[k] = v
      end
    end
    thash
  end

  # Do some clean-up on the string returned from REST calls.  Removes some
  # quote characters embedded in the string and other misc.
  #
  # @param [String] str string returned from REST call
  # @return [String] sanitized string
  def sanitize_str(str)
    str.gsub!(/['"]/,'')
    str.chomp!
    str
  end

end # Zenoss

require 'zenoss/connection'
require 'zenoss/exceptions'
require 'zenoss/model'
require 'zenoss/events'

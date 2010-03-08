#############################################################################
# Copyright © 2010 Dan Wanek <dwanek@nd.gov>
#
#
# This file is part of Zenoss-RubyREST.
# 
# Zenoss-RubyREST is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# Zenoss-RubyREST is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with Zenoss-RubyREST.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
require 'rubygems'
require 'date'
require 'tzinfo'
require 'uri'

# String is extended to for method renaming purposes
class String
  def ruby_case
    self.split(/(?=[A-Z])/).join('_').downcase
  end

  def camel_case
    self.split(/_/).map {|word| word.capitalize}.join
  end
end

# Class is extended in order to add Zenoss REST methods declaratively.
class Class

  # Takes a Hash as an argument in the form {:ruby_name => 'RestName'}
  def zenoss_list(methods)
    methods.each_pair do |ruby_name,rest_name|
      add_to_zenoss_methods(ruby_name)

      define_method(ruby_name) do
        plist_to_array( rest(rest_name) )
      end
    end
  end

  def zenoss_datetime(methods)
    methods.each_pair do |ruby_name,rest_name|
      add_to_zenoss_methods(ruby_name)

      define_method(ruby_name) do
        pdatetime_to_datetime( rest(rest_name) )
      end
    end
  end

  def zenoss_string(methods)
    methods.each_pair do |ruby_name,rest_name|
      add_to_zenoss_methods(ruby_name)

      define_method(ruby_name) do
        rest(rest_name)
      end
    end
  end

  def zenoss_int(methods)
    methods.each_pair do |ruby_name,rest_name|
      add_to_zenoss_methods(ruby_name)

      define_method(ruby_name) do
        retval = rest(rest_name)
        retval.to_i unless retval.nil?
      end
    end
  end
  
  def zenoss_boolean(methods)
    methods.each_pair do |ruby_name,rest_name|
      add_to_zenoss_methods(ruby_name)

      define_method(ruby_name) do
        (rest(rest_name)).eql?('True') ? true : false
      end
    end
  end



  private

  # Update the class variable @@zenoss_methods with this method
  def add_to_zenoss_methods(method_sym)
    z_methods = class_variable_get(:@@zenoss_methods)
    z_methods << method_sym.to_s
    class_variable_set(:@@zenoss_methods, z_methods)
  end
end

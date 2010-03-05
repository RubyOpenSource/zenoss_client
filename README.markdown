This is a work-in-progress to create an easy to use client REST API for
Zenoss (http://www.zenoss.com) written in Ruby.  I love Zenoss as a
product, but I am much more efficient in Ruby than Python so I decided
to start hacking this library together.  It is very incomplete and I am
just adding functionality as I need it or it is requested.

Cheers,

Dan Wanek


TO USE:
-------
	require 'zenoss'

	# You must set the URI before doing anything else
	Zenoss.uri 'https://zenhost:port/zport/dmd/'

	# Add the appropriate credentials
	Zenoss.set_auth('user','pass')
	
	# This returns the base DeviceClass '/zport/dmd/Devices'
	# It is the equivilent in zendmd of 'dmd.Devices'
	devices = Zenoss.devices
	# Search for a device
	dev = devices.find_device_path('devname')
	# Get the uptime of the device
	dev.sys_uptime

---------

Have fun and let me know what needs to be fixed / added.

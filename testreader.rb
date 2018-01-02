=begin rdoc
=Example Program
==test_thinkifyreader.rb	

This program shows how to open a connection to the reader, show the firmware 
version, read tags, and play with the LEDs...
 
Copyright 2011, Thinkify LLC. All rights reserved.
=end

#append the current directory to the search path
$: << File.dirname(__FILE__)


#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"","thinkify_api")
# $: << File.join(File.dirname(__FILE__),"..","thinkify_api")

#require our library
require 'thinkifyreader'
# Create a reader to work with. 
# On windows you can just call .new and the class will scan for the first reader it can find (upto com20)
# Under linux, you must specify the /dev/ttyXX file descriptor to use:


  puts "Create a Reader"

  r = ThinkifyReader.new('/dev/ttyUSB0') #Linux Ubuntu
#  r   = ThinkifyReader.new  #Windows

  puts "Make sure reading is not active"
  r.reading_active=false

  puts "Query the reader's firmware version."
	puts "Reader's Firmware Version: #{r.version}"
	


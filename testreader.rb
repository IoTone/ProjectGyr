# =begin rdoc
# =Example Program
# ==test_thinkifyreader.rb
#
# This program shows how to open a connection to the reader, show the firmware
# version, read tags, and play with the LEDs...
#
# Copyright 2011, Thinkify LLC. All rights reserved.
# =end
#
# #append the current directory to the search path
# $: << File.dirname(__FILE__)
#
#
# #Add the default relative library location to the search path
# $: << File.join(File.dirname(__FILE__),"","thinkify_api")
# # $: << File.join(File.dirname(__FILE__),"..","thinkify_api")
#
# #require our library
# require 'thinkifyreader'
# # Create a reader to work with.
# # On windows you can just call .new and the class will scan for the first reader it can find (upto com20)
# # Under linux, you must specify the /dev/ttyXX file descriptor to use:
#
#
#   puts "Create a Reader"
#
#   r = ThinkifyReader.new('/dev/ttyUSB0') #Linux Ubuntu
# #  r   = ThinkifyReader.new  #Windows
#
#   puts "Make sure reading is not active"
#   r.reading_active=false
#
#   puts "Query the reader's firmware version."
# 	puts "Reader's Firmware Version: #{r.version}"


# { "_id" : ObjectId("5a3d5c79b7e24d2328000002"), "count" : 33, "epc" : "3000 3008 33B2 DDD9 0140 0000 0000", "discovery" : "2017/12/22 14:26:48.755", "rssi" : "24.95310179804325", "last_tag_read" : "2017-12-22T15:15:34+00:00", "time_difference" : 48, "read" : 2 }
# { "_id" : ObjectId("5a3d5cfcb7e24d2328000004"), "count" : 22, "epc" : "3000 E200 2064 8614 0167 0560 DA5C", "discovery" : "2017/12/22 14:28:56.826", "rssi" : "2.9531017980432495", "last_tag_read" : "2017/12/22 14:28:58.838", "time_difference" : 0, "read" : 1 }
# { "_id" : ObjectId("5a4b3d4cb7e24d0c30000002"), "count" : 40, "epc" : "3000 3008 33B2 DDD9 0140 0000 0100", "discovery" : "2017/12/27 14:26:48.755", "rssi" : "234234", "last_tag_read" : "2017-12-30T14:26:48+00:00", "time_difference" : 4320,"read" : 3 }
# { "_id" : ObjectId("5a4c04c5b7e24d1278000002"), "count" : 40, "epc" : "3000 3008 3372 DDD9 0140 0000 0100", "discovery" : "2017/12/30 14:26:48.755", "rssi" : "234234", "last_tag_read" : "2017/12/30 14:26:48.755", "time_difference" : 0, "read" : 1 }
# { "_id" : ObjectId("5a4c06f5b7e24d1278000004"), "count" : 40, "epc" : "3000 3708 3372 DDD9 0140 0000 0100", "discovery" : "2017/12/30 14:26:48.755", "rssi" : "234234", "last_tag_read" : "2017/12/30 14:26:48.755", "time_difference" : 0, "read" : 1 }
# { "_id" : ObjectId("5a4c08d4b7e24d1278000006"), "count" : 40, "epc" : "3000 3708 3372 DDD9 0440 0000 0100", "discovery" : "2017/12/30 14:26:48.755", "rssi" : "234234", "last_tag_read" : "2017/12/30 14:26:48.755", "time_difference" : 0, "read" : 1 }

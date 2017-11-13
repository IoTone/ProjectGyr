require 'mongo'

#Creating a connection to database
client = Mongo::Client.new(['127.0.0.1:27017'], :database => 'test')

puts "#{client.cluster.servers.inspect}"


#append the current directory to the search path
$: << File.dirname(__FILE__)

#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"","thinkify_api")

#require our library
require 'thinkifyreader'

# Create a reader to work with.
# On windows you can just call .new and the class will scan for the first reader it can find (upto com20)
# Under linux, you must specify the /dev/ttyXX file descriptor to use:

  #r = ThinkifyReader.new('/dev/ttyACM0') #Linux Ubuntu

  r = ThinkifyReader.new #Windows

    r.reading_active=false

  puts "Query the reader's firmware version."
	puts "Reader's Firmware Version: "
  puts "#{r.version}"

# Show the inventory parameters
	puts
	puts "Inventory Parameters:"
  puts r.inventory_params


# Turn the reader on (start reading tags using default parameters)
  puts
  puts "Reading Tags:"
  r.reading_active=true

	begin

			# Read for a few seconds...
			sleep(3)

			# The reader will put the tags it finds into its tag_list... An array of tags.
			puts "Total Tags: #{r.tag_list.length}"

			# Report what it found...
			r.tag_list.each do |tag|
				puts "EPC: #{tag.epc}"
        puts "Count:  #{tag.count}"
        puts "Time of Discovery: #{tag.disc}"
        puts "Signal Strength: #{tag.rssi}"
			end

			# Clear its tag list.
			r.tag_list.clear

	rescue Exception

	  puts "Exception Thrown."

	ensure

		# Turn off reading.
		r.reading_active=false

	end

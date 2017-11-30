#append the current directory to the search path
$: << File.dirname(__FILE__)

#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"","thinkify_api")

#require our library
require 'thinkifyreader'
require 'sinatra'
require './models/mongo_db'
# Create a reader to work with.
# On windows you can just call .new and the class will scan for the first reader it can find (upto com20)
# Under linux, you must specify the /dev/ttyXX file descriptor to use:

  #r = ThinkifyReader.new('/dev/ttyACM0') #Linux Ubuntu

   r = ThinkifyReader.new #Windows

   r.reading_active=false
# Route for main page
   get '/' do
     @time = Time.now
     @version = r.version
     @reading = r.reading_active
     r.raise_errors = false
     erb :index
   end

   get '/taglist' do
    @reading_active = r.reading_active

    @tag_list = r.tag_list.filter(/.*/).sort
    r.tag_list.clear
    erb :taglist
   end

   get '/tags' do
    @reading_active = r.reading_active
    @tag_list = r.tag_list
    @inventory_params = r.inventory_params
    @count = r.tag_list.length
    erb :tags
   end

   post '/tags' do
    command = (params["reader_command"].downcase)
    @reader_response = r.execute(command).gsub("\r", "<br>")
    erb :tags
   end

# # Show the inventory parameters
# 	puts
# 	puts "Inventory Parameters:"
#   puts "#{r.inventory_params}"
#
#
# # Turn the reader on (start reading tags using default parameters)
#   puts
#   puts "Reading Tags:"
#   r.reading_active=true
#
# 	begin
#
# 			# Read for a few seconds...
# 			sleep(3)
#
# 			# The reader will put the tags it finds into its tag_list... An array of tags.
# 			puts "Total Tags: #{r.tag_list.length}"
#
# 			# Report what it found...
# 			r.tag_list.each do |tag|
# 				puts "EPC: #{tag.epc}"
#         puts "Count:  #{tag.count}"
#         puts "Time of Discovery: #{tag.disc}"
#         puts "Signal Strength: #{tag.rssi}"
#         puts "last time tag was read #{tag.last}"
# 			end
#
# 			# Clear its tag list.
# 			r.tag_list.clear
#
# 	rescue Exception
#
# 	  puts "Exception Thrown."
#
# 	ensure
#
# 		#Turn off reading.
# 		r.reading_active=false
#
# 	end

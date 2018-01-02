#append the current directory to the search path
$: << File.dirname(__FILE__)

#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"","thinkify_api")

#require our library
require 'thinkifyreader'
require 'httparty'
require 'sinatra'
require './models/mongo_db'
require 'net/http'
require 'uri'
require 'json'
require 'pry-byebug'
# Create a reader to work with.
# On windows you can just call .new and the class will scan for the first reader it can find (upto com20)
# Under linux, you must specify the /dev/ttyXX file descriptor to use:

r = ThinkifyReader.new('/dev/ttyUSB0') #ArchLinux
# r = ThinkifyReader.new('/dev/ttyACM0') #Linux Ubuntu

# r = ThinkifyReader.new #Windows

# Set active reading to false
   r.reading_active=false

#API to grab tags
   get '/taglist' do
    content_type :json
    @all_tags = Tag.all
    @all_tags.to_json
   end

# Route for main page

   get '/' do
    @reading_active = r.reading_active=true
    @tag_list = r.tag_list
    @inventory_params = r.inventory_params
    @count = r.tag_list.length
    @newTags = []
    @all_tags = Tag.all

    @tag_list.each do |tag|
      @result = HTTParty.post("http://localhost:9292/",
        :body => {
          epc: tag.epc,
          count: tag.count,
          discovery: tag.disc,
          rssi: tag.rssi,
          last_tag_read: tag.last
        }.to_json,
        :headers => {'Content-Type' => 'application/json'}
      )

        @newTags << JSON.parse(@result.body)
    		end

        @tag_list.clear

      erb :dashboard
   end


    post '/' do

      content_type :json
      parse_params = JSON.parse(request.body.read)

        @tag = Tag.find_by_epc(parse_params['epc'])
        if @tag.nil?
          read = 1
          time_difference = 0
          parse_params['time_difference'] = time_difference
          parse_params['read'] = read
          @tag = Tag.new(parse_params)
          @tag.save
        else
          #Increment times tag has been read
          @tag.read += 1

          #Time difference calculation
          current_discovery = DateTime.parse(parse_params['discovery'])
          previous_discovery = DateTime.parse(@tag.discovery)

          start_time = previous_discovery
          end_time = current_discovery

          #Update last time
          last_tag_read = DateTime.parse(parse_params['last_tag_read']).strftime('%FT%T%:z')

          @tag.update_attributes(:time_difference => TimeDifference.between(start_time, end_time).in_minutes, :last_tag_read => last_tag_read)
        end
       {epc: @tag.epc, count: @tag.count, rssi: @tag.rssi, discovery: @tag.discovery, last_tag_read: @tag.last_tag_read, time_difference: @tag.time_difference, read: @tag.read}.to_json
   end

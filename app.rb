require 'httparty'
require 'sinatra'
require './models/mongo_db'
require 'net/http'
require 'uri'
require 'json'
require 'pry-byebug'
require 'time_difference'
# require './gyr_reader_tier'

# API to grab tags
get '/taglist' do
    content_type :json
    @all_tags = TAGS.find.to_a

    u_interval_5 = 0
    u_interval_30 = 0
    u_interval_60 = 0
    u_interval_8 = 0
    u_interval_24 = 0

    r_interval_5 = 0
    r_interval_30 = 0
    r_interval_60 = 0
    r_interval_8 = 0
    r_interval_24 = 0

    @interval_array = []

    @new_array = @all_tags.map do |t|
      @tag = t
      end_time = DateTime.now.strftime("%Y/%m/%d %H:%M:%S.%L")
      start_time = @tag['last_tag_read']
      time_difference = TimeDifference.between(start_time, end_time).in_minutes

      TAGS.update_one({epc: @tag['epc'] }, '$set' => { 'time_difference' => time_difference })
      @tag
    end

	@new_array.each do |tag|

   if tag['time_difference'] < 1
      u_interval_5 += 1
      u_interval_30 += 1
      u_interval_60 += 1
      u_interval_8 += 1
      u_interval_24 += 1
    elsif tag['time_difference'] > 1 && tag['time_difference'] < 1.50
      u_interval_30 += 1
      u_interval_60 += 1
      u_interval_8 += 1
      u_interval_24 += 1
    elsif tag['time_difference'] >= 1.50 && tag['time_difference'] < 2
      u_interval_60 += 1
      u_interval_8 += 1
      u_interval_24 += 1
    elsif tag['time_difference'] >= 2 && tag['time_difference'] < 2.50
      u_interval_8 += 1
      u_interval_24 += 1
    elsif tag['time_difference'] >= 2.50 && tag['time_difference'] < 3
      u_interval_24 += 1
    else
      puts "Tags updated"
   end
    @interval_array << { u_interval_5: u_interval_5 , u_interval_30: u_interval_30, u_interval_60: u_interval_60, u_interval_8: u_interval_8, u_interval_24: u_interval_24 }
   end
    @interval_array.to_json
  end #get

# Route for main page

   get '/' do

    @all_tags = TAGS.find.sort(_id: -1).limit(3)

    if RUBY_PLATFORM.include?("linux")
      @platform = "linux"
      @com = "/dev/ttyACM0"
    elsif RUBY_PLATFORM.include?("mingw32")
      @platform = "mingw32"
      @com = "Com"
    elsif RUBY_PLATFORM.include?("mswin32")
      @platform = 'mswin32'
      @com = "com"
    else
      @platform = "Unkown"
    end

    erb :dashboard
   end

   post '/output' do
     TAGS.delete_many({})
     redirect '/'
   end

   get '/taglist_2' do
     content_type :json

     @all_tags = TAGS.find.to_a

     @all_tags.to_json
   end

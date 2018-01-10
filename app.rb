require 'httparty'
require 'sinatra'
require './models/mongo_db'
require 'net/http'
require 'uri'
require 'json'
require 'pry-byebug'
require 'time_difference'

# API to grab tags
get '/taglist' do
    content_type :json
    @all_tags = TAGS.find.to_a

    u_interval_5 = 0
    u_interval_30 = 0
    u_interval_60 = 0

    r_interval_5 = 0
    r_interval_30 = 0
    r_interval_60 = 0

    @interval_array = []

    @new_array = @all_tags.map do |t|
      @tag = t
      end_time = DateTime.now.strftime("%Y/%m/%d %H:%M:%S.%L")
      start_time = @tag['discovery']
      time_difference = TimeDifference.between(start_time, end_time).in_minutes

      TAGS.update_one({epc: @tag['epc'] }, '$set' => { 'time_difference' => time_difference })
      @tag
    end

	@new_array.each do |tag|

    if tag['read'] > 1 && tag['time_difference'] < 5
      r_interval_5 +=1
    elsif tag['read'] > 1 && tag['time_difference'] > 5 && tag['time_difference'] < 30
      r_interval_30 +=1
    elsif tag['read'] > 1 && tag['time_difference'] >= 30 && tag['time_difference'] < 60
      r_interval_60 +=1
    elsif tag['read'] == 1 && tag['time_difference'] < 5
      u_interval_5 +=1
    elsif tag['read'] == 1 && tag['time_difference'] > 5 && tag['time_difference'] < 30
      u_interval_30 +=1
    elsif tag['read'] == 1 && tag['time_difference'] >= 30 && tag['time_difference'] < 60
      u_interval_60 += 1
    else
      puts "Tags updated"
    end
    @interval_array << { r_interval_5: r_interval_5 , r_interval_30: r_interval_30 , r_interval_60: r_interval_60 , u_interval_5: u_interval_5 , u_interval_30: u_interval_30, u_interval_60: u_interval_60 }
   end
    @interval_array.to_json
  end #get


# Route for main page

   get '/' do

    @all_tags = TAGS.find.sort(_id: -1).limit(3)

    erb :dashboard
   end

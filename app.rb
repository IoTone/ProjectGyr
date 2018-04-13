require 'httparty'
require 'sinatra'
require './models/mongo_db'
require 'net/http'
require 'uri'
require 'json'
require 'pry-byebug'
require 'time_difference'
require 'yaml'

config = YAML::load_file(File.join(__dir__, "gyruss_values.yml"))
# require './gyr_reader_tier'

# API to grab tags
get '/taglist' do
    content_type :json
    @reads = READS.find.to_a
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

   @counter = @reads.map do |r|
     @read = r

     end_time_r = DateTime.now.strftime("%Y/%m/%d %H:%M:%S.%L")
     start_time_r = @read['discovery']
     time_difference_repeat = TimeDifference.between(start_time_r, end_time_r).in_minutes

     @read['time_difference_repeat'] = time_difference_repeat

     @read
    end

   @new_array = @all_tags.map do |t|
      @tag = t
      end_time_u = DateTime.now.strftime("%Y/%m/%d %H:%M:%S.%L")
      start_time_u = @tag['last_tag_read']

      time_difference_unique = TimeDifference.between(start_time_u, end_time_u).in_minutes

      @tag['time_difference_unique'] = time_difference_unique

      @tag
    end

	@new_array.each do |tag|

  if tag['time_difference_unique'] < 5
      u_interval_5 += 1
      u_interval_30 += 1
      u_interval_60 += 1
      u_interval_8 += 1
      u_interval_24 += 1
   elsif tag['time_difference_unique'] > 5 && tag['time_difference_unique'] < 30
      u_interval_30 += 1
      u_interval_60 += 1
      u_interval_8 += 1
      u_interval_24 += 1
   elsif tag['time_difference_unique'] > 30 && tag['time_difference_unique'] < 60
      u_interval_60 += 1
      u_interval_8 += 1
      u_interval_24 += 1
   elsif tag['time_difference_unique'] > 60 && tag['time_difference_unique'] < 480
      u_interval_8 += 1
      u_interval_24 += 1
   elsif tag['time_difference_unique'] > 480 && tag['time_difference_unique'] < 1440
      u_interval_24 += 1
   else
     puts "Uniques udpated"
  end
    @interval_array << { u_interval_5: u_interval_5 , u_interval_30: u_interval_30, u_interval_60: u_interval_60, u_interval_8: u_interval_8, u_interval_24: u_interval_24 }
  end

  @counter.each do |count|

    if count['time_difference_repeat'] < 5
       r_interval_5 += 1
       r_interval_30 += 1
       r_interval_60 += 1
       r_interval_8 += 1
       r_interval_24 += 1
    elsif count['time_difference_repeat'] > 5 && count['time_difference_repeat'] < 30
       r_interval_30 += 1
       r_interval_60 += 1
       r_interval_8 += 1
       r_interval_24 += 1
    elsif count['time_difference_repeat'] > 30 && count['time_difference_repeat'] < 60
       r_interval_60 += 1
       r_interval_8 += 1
       r_interval_24 += 1
    elsif count['time_difference_repeat'] > 60 && count['time_difference_repeat'] < 480
       r_interval_8 += 1
       r_interval_24 += 1
    elsif count['time_difference_repeat'] > 480 && count['time_difference_repeat'] < 1440
       r_interval_24 += 1
    else
        puts "Repeats updated"
    end
    @interval_array << { r_interval_5: r_interval_5, r_interval_30: r_interval_30, r_interval_60: r_interval_60, r_interval_8: r_interval_8, r_interval_24: r_interval_24 }
  end

    @interval_array.to_json
  end #get

# Route for main page

  get '/' do
   erb :dashboard
  end

   get '/settings' do

    @all_tags = TAGS.find.sort(_id: -1).limit(3)

    @linger_threshold = config['linger_threshold']

    @reader_duty_cycle = config['reader_duty_cycle']

    @reader_status = config['status_of_connection']

    @serial_port = config['serial_port']

    @reader_ID = config['reader_ID']

    if RUBY_PLATFORM.include?("linux")
      @platform = "linux"
    elsif RUBY_PLATFORM.include?("mingw32")
      @platform = "mingw32"
    elsif RUBY_PLATFORM.include?("mswin32")
      @platform = 'mswin32'
    else
      @platform = "Unkown"
    end

    erb :settings
   end

   post '/output' do
     TAGS.delete_many({})
     READS.delete_many({})
     redirect '/'
   end

   get '/taglist_2' do
     content_type :json

     @all_tags = READS.find.to_a

     @all_tags.to_json
   end

   get '/debug' do

     erb :debug
   end

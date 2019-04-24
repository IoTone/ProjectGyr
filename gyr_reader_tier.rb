#append the current directory to the search path
$: << File.dirname(__FILE__)

#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"","thinkify_api")

# #require our library
require 'thinkifyreader'
require './models/mongo_db'
require './newTag'
require './testTag'
require 'yaml'
require 'pry-byebug'
require 'time_difference'

class ReaderApp

  @@config = YAML::load_file(File.join(__dir__, "gyruss_values.yml"))

  def persist

    @tag_list = @r.tag_list
    # @tag_list = []
    #
    # @tag_list << Testtag.new("PX2D Z9O4 YD4I N9LO JFKU SUHW B2N7", "50.95310179804325", 16, "2018/11/06 11:20:00.000", "2018/11/06 11:20:00.000")

    counter = Read.new
    repeat = Repeat.new
    newtag = Newtag.new

    @tag_list.each do |t|

      counter.discovery = t.disc
      counter.epc = t.epc
      counter.rssi = t.rssi
      counter.count = t.count

      repeat.discovery = t.disc
      repeat.epc = t.epc
      repeat.rssi = t.rssi
      repeat.count = t.count

      newtag.epc = t.epc
      newtag.count = t.count
      newtag.discovery = t.disc
      newtag.rssi = t.rssi
      newtag.last_tag_read = t.last
     end

     g = {}
     counter.instance_variables.each {|var| g[var.to_s.delete("@")] = counter.instance_variable_get(var) }
     g

     READS.insert_one(g)

      @tag = TAGS.find(epc: newtag.epc).to_a

      linger_threshold = @@config["linger_threshold"]

      if @tag.empty? && newtag.epc
        read = 1
        time_difference_unique = 0

        newtag.time_difference_unique = time_difference_unique
        newtag.read = read

        tag = Tag.new

        tag.epc = newtag.epc
        tag.count = newtag.count
        tag.discovery = newtag.discovery
        tag.rssi = newtag.rssi
        tag.last_tag_read = newtag.last_tag_read
        tag.read = newtag.read
        tag.time_difference_unique = newtag.time_difference_unique

        h = {}
        tag.instance_variables.each {|var| h[var.to_s.delete("@")] = tag.instance_variable_get(var) }
        h

         TAGS.insert_one(h)
      elsif @tag && newtag.epc

        #Increment times tag has been read
        increment = {}
        @tag.map { |h| increment = h }
        increment['read'] += 1
        number = increment['read']

        end_time = DateTime.now.strftime("%Y/%m/%d %H:%M:%S.%L")
        start_time = @tag[0]['last_tag_read']

        time_difference = TimeDifference.between(start_time, end_time).in_minutes

        if @tag[0]['read'] > 1 && time_difference > linger_threshold
          j = {}
          repeat.instance_variables.each {|var| j[var.to_s.delete("@")] = repeat.instance_variable_get(var) }
          j

          REPEATS.insert_one(j)
        end

        TAGS.update_one({epc: newtag.epc }, '$set' => { 'read' => number })

      else
        puts "Taglist empty"
      end
  end

  # ****************************************************************************
  # Create a reader grab our configuraiton and get ready to run
  # ****************************************************************************
  def initialize
    # The PC this code is running on provides the networking / mac address we use
    #in the DB. Let's make a "reader" in the DB using these paramters.

    #We can specify parameters in a config file for easier deployment.
    @tag_added = false

    # Create a thinkify reader to work with.
    # On windows you can just call .new and the class will scan for the first reader
    # it can find (upto com20)
    if RUBY_PLATFORM.include?("linux")
      puts("Configure linux reader on  /dev/ttyUSB0")
      @r = ThinkifyReader.new('/dev/ttyUSB0') #Linux Ubuntu
      # @r = ThinkifyReader.new('/dev/ttyACM0') #Linux Ubuntu
    end

    if RUBY_PLATFORM.include?("mingw32")
      puts("Configure windows reader")
      @r = ThinkifyReader.new
    end

    if RUBY_PLATFORM.include?("mswin32")
      puts("Configure windows reader")
      @r = ThinkifyReader.new
    end

    # Our API supports a callback mechanism. Simply tie a block to the .tag_added or
    # .tag_updated or .tag_removed to perform a set of tasks whenever these events
    # occur.
    #puts "setting up tag added callback"
    # When we first observe a tag, add it to the db if it doesn't exist and then add
    # an 'added' event.
    @r.tag_list.tag_added do |tag|
      puts "A new tag was seen!  #{tag.epc}"
      @tag_added = true #We just set a flag...
    end

  end

  # ****************************************************************************
  # Do one cycle to do notification.
  #****************************************************************************
  def run_cycle

    @r.reading_active=true

      # Read for a few seconds...
        sleep(@@config['reader_duty_cycle'])

        # The reader will put the tags it finds into its tag_list... An array of tags.
        puts "Total Tags: #{@r.tag_list.length}"

        if @tag_added
          #We've got at least one new tag on the list. -- Report the new Tags...
           @r.tag_list
          @tag_added = false
          persist
        end

        #Clean out Stale tags.
        @r.tag_list.clear

  end

  def run

    puts
    puts "Reading Tags:"
    @r.reading_active=true

    # puts "lifetime"
    # p @r.tag_list.tag_lifetime

    if @r.connected == true
      puts "Reader connected"
    end

    begin

    while(1)
      run_cycle
    end

    rescue Exception

      puts "Exception Thrown."
      p $!

    ensure

      # Turn off reading.
      @r.reading_active=false

    end

  end

end
 #***********************************************************
 # Make an instance and Go!

 rn = ReaderApp.new()

 rn.run
 
  # rn.persist

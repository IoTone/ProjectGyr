#append the current directory to the search path
$: << File.dirname(__FILE__)

#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"","thinkify_api")

# #require our library
require 'thinkifyreader'
require './models/mongo_db'
require './newTag'
require './testTag'
# require 'pry-byebug'
require 'time_difference'

class ReaderApp

  def persist
    @tag_list = @r.tag_list
    # @tag_list = []

    # @tag_list << Testtag.new("G0SK J7X3 FZ7S GZL9 0Y4N JN8L A1W9", "50.95310179804325", 16, "2018/03/03 22:23:00.000", "2018/03/04 01:58:00.000")


    newtag = Newtag.new

    @tag_list.each do |t|
          newtag.epc = t.epc
          newtag.count = t.count
          newtag.discovery = t.disc
          newtag.rssi = t.rssi
          newtag.last_tag_read = t.last
        end

      @tag = TAGS.find(epc: newtag.epc).to_a

      if @tag.empty? && newtag.epc
        read = 1
        time_difference = 0
        newtag.time_difference = time_difference
        newtag.read = read

        tag = Tag.new

        tag.epc = newtag.epc
        tag.count = newtag.count
        tag.discovery = newtag.discovery
        tag.rssi = newtag.rssi
        tag.last_tag_read = newtag.last_tag_read
        tag.read = newtag.read
        tag.time_difference = newtag.time_difference

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
        #Time difference calculation
        current_discovery = DateTime.parse(newtag.discovery)
        new_discovery = newtag.discovery

        time = {}
        @tag.map { |t| time = t }

        previous_discovery = DateTime.parse(time['discovery'])

        # start_time = previous_discovery
        # end_time = current_discovery

        #Update last time
        # last_tag_read = newtag.last_tag_read
        # last_tag_read = DateTime.parse(newtag.last_tag_read).strftime('%FT%T%:z')

        TAGS.update_one({epc: newtag.epc }, '$set' => { 'read' => number, 'discovery' => new_discovery })

      else
        puts "Taglist empty"
      end
      # return @tag
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
    # @r = ThinkifyReader.new('/dev/ttyUSB0') #ArchLinux
     @r = ThinkifyReader.new('/dev/ttyACM0') #Linux Ubuntu
     # @r = ThinkifyReader.new


    # r = ThinkifyReader.new #Windows

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
        sleep(3)

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
rn.persist

#append the current directory to the search path
$: << File.dirname(__FILE__)

#Add the default relative library location to the search path
$: << File.join(File.dirname(__FILE__),"","thinkify_api")

# require our library
require 'thinkifyreader'
require './models/mongo_db'
require './newTag'

class ReaderApp

  def persist
    @tag_list = @r.tag_list

    newtag = Newtag.new

    @tag_list.each do |t|
          newtag.epc = t.epc
          newtag.count = t.count
          newtag.discovery = t.disc
          newtag.rssi = t.rssi
          newtag.last_tag_read = t.last
        end

      @tag = TAGS.find(newtag.epc)
      if @tag.nil?
        read = 1
        time_difference = 0
        newtag.time_difference = time_difference
        newtag.read = read
        @tag = Tag.new

        @tag.epc = newtag.epc
        @tag.count = newtag.count
        @tag.discovery = newtag.discovery
        @tag.rssi = newtag.rssi
        @tag.last_tag_read = newtag.last_tag_read

        @tag.save()
      else
        #Increment times tag has been read
        @tag.read += 1

        #Time difference calculation
        current_discovery = DateTime.parse(newtag.discovery)
        previous_discovery = DateTime.parse(@tag.discovery)

        start_time = previous_discovery
        end_time = current_discovery

        #Update last time
        last_tag_read = DateTime.parse(newtag.last_tag_read).strftime('%FT%T%:z')

        @tag.update_attributes(:time_difference => TimeDifference.between(start_time, end_time).in_minutes, :last_tag_read => last_tag_read)
      end
      return @tag
  end

  #****************************************************************************
  #Create a reader grab our configuraiton and get ready to run
  #****************************************************************************
  def initialize
    # The PC this code is running on provides the networking / mac address we use
    #in the DB. Let's make a "reader" in the DB using these paramters.

    #We can specify parameters in a config file for easier deployment.
    @tag_added = false

    # Create a thinkify reader to work with.
    # On windows you can just call .new and the class will scan for the first reader
    # it can find (upto com20)
    @r = ThinkifyReader.new('/dev/ttyUSB0') #ArchLinux
    # r = ThinkifyReader.new('/dev/ttyACM0') #Linux Ubuntu

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

      # Read for a few seconds...
        sleep(3)

        # The reader will put the tags it finds into its tag_list... An array of tags.
        puts "Total Tags: #{@r.tag_list.length}"

        if @tag_added
          #We've got at least one new tag on the list. -- Report the new Tags...
          @tag_added = false
          persist
        end

        #Clean out Stale tags.
        @r.tag_list.delete_stale_tags!()

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

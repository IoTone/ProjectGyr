=begin rdoc
=Thinkify Serial Connection Tester Class
==test_serialconnection.rb

For Engineering Use.
(To test performance of serial connection on different operating systems.)

Not a customer-facing module/class.

Copyright 2011, Thinkify LLC. All rights reserved.
=end

require_relative 'serialconnection'
require_relative 'methodbuilder'
require_relative 'thinkifytaglist'
require_relative 'thinkifycallbacks'

class TestSerialConnection< SerialConnection

  attr_reader :reading_tags

  # When scanning for a reader we need to know which OS we're running...
  def my_os

    if RUBY_PLATFORM.include?("linux")
      return :linux
    end

    if RUBY_PLATFORM.include?("mingw32")
      return :cygwin
    end

    if RUBY_PLATFORM.include?("mswin32")
      return :windows
    end

    return :unknown

  end


  # Call the initializer and build lots of the Getters/Setters from a reader
  # methods file. Default value for the methods file will be the file,
  # readermethods.dat found in the same directory as this file,
  # thinkifyreader.rb.
  def initialize(com=nil)

  	methodsfile=File.join(File.dirname(__FILE__) , "readermethods.dat")


  	@data = ""

  	if com.nil?

  	  case my_os

        when :windows, :cygwin

			    #look for a reader on comports 1 to 20
			    0.upto(19) do |p|
				    begin
		      		super(p)
		      		puts "Reader Found on COM#{p+1}"
		      		break
				    rescue Exception
				    	p $!
					    puts "No Reader on COM#{p+1}"
				    end
			    end

		    when :linux

		      com = '/dev/ttyACM0'

		    	begin
		    		super(com)
		    		puts "Reader Found on #{com}"
				  rescue Exception
					  puts "No Reader on #{com}"
					  raise 'Unable to connect to reader using default linux descriptor.'
				  end

		    else #Nothing to do...

		      puts "Unknown operating system..."
		      raise 'Operating System Unknown. --Not sure how to find the reader'

		  end

		else

		    #try connecting to what they give us...
				begin
		  		super(com)
		  		puts "Reader Found on #{com}"
				rescue Exception
					puts "No reader found on #{com}."
					raise 'Unable to connect to reader using supplied descriptor. --Is reader plugged in?'
				end

    end

    #Our interface has two modes: Synchronous command-response and streaming
    #The streaming interface is used when the reader is spinning, looking for tags
    #We need a flag to know how to treat data when in comes in on the serial port
    @reading_tags = false

    @tag_list = ThinkifyTagList.new

    #mutex so rx_buf doesn't get screwed up w/ multi-threaded access
    @taglist_mutex = Mutex.new

    @reading_tags=false

    send_receive("") #This will die if we failed to initialize properly...

  end

private

  #Override the parent routine in serialconnection.
  def process_rx_buf(line_marker)

    #If we're in streaming mode, grab the data as it comes in. Otherwise, just wait for the receive function to deal with it.

		temp = ""

    if @reading_tags

    	@mutex.synchronize{

      	temp = @rx_buf[0..line_marker]
      	@rx_buf=@rx_buf[(line_marker+2)..@rx_buf.length]

  	  }

    	@data << temp << "\r\n"

    end

  end

public

  def data
  	@data
  end


	def rx_buf
		@rx_buf
	end

	def rx_buf=(newvalue)
		@rx_buf=newvalue
	end


  #Send a command to the reader and return the response. If reading, pause while we execute the command and recommence afterwards.
  def execute(s)
    if self.reading_active
       self.reading_active=false
       reply= super(s)
       self.reading_active=true
    else

       reply= super(s)
    end

    return reply
  end

	def tag_list
		@tag_list
	end

  def clear_tag_list
  	self.tag_list.clear
  end

  def reading_active
    @reading_tags
  end

  def reading_active=(newvalue)

    #p "in reading_active New val: #{newvalue}"

    if newvalue and !@reading_tags then
      #Turn on Polling...
      @reading_tags = true
      send("t6") #start reading...

    else

      @reading_tags=false
      send_receive("")

    end

  end

end

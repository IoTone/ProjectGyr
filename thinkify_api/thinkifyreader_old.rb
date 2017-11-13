=begin rdoc
=Thinkify Reader Class
==thinkifyreader.rb	

ThinkifyReader is a fairly lightweight class that inherits from SerialConnection. It provides methods that map attributes to reader functions like readername, readertype, etc, and exposes the execute method to send/receive an arbitrary command to the reader. 

This class uses a metaprogramming hack to dynamically build methods for many of the simple reader attributes from a file. This is a pretty flexible way to create the class and avoid lots of repetitive coding. 

Copyright 2011, Thinkify LLC. All rights reserved.
=end

require 'serialconnection'
require 'methodbuilder'
require 'thinkifytaglist'
require 'thinkifycallbacks'

class ThinkifyReader< SerialConnection
  #this little statement, in inconjuction w/ build_methods, above creates a bunch of methods for the class that can be configured out of a file. Simple getters and setters are created that use the serial interface to talk to the module to manipulate the reader parameters. 
  include MethodBuilder  

  @@methods_needed = true 
   
  attr_reader :reading_tags
  
  attr_reader :connected 
  
  #Callback mechanism for event-driven programming
  extend Callbacks
  callback :data_received
  callback :data_sent 
  
  #When scanning for a reader we need to know which OS we're running...
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
  def initialize(com=nil, debug_com = false)
    
    @debug_com=debug_com
    
    @connected = false
    
    methodsfile=File.join(File.dirname(__FILE__) , "readermethods.dat")
    
    if com.nil? 
       
      case my_os

        when :windows, :cygwin
            
          #Under Windows, look for a reader on comports 1 to 20 	
          0.upto(19) do |p|
            if @debug_com
              print "." 
            end
            #puts "Scanning COM #{p+1}"
            begin
              super(p)
              if @debug_com
                puts "ReaderFound on COM#{p+1}"
              end
              @connected = true
              break
            rescue Exception
              #p $!
              #puts "No Reader on COM#{p+1}"
            end
          end
      
        when :linux
          
          com = '/dev/ttyACM0'
          
          begin
            super(com)
            if @debug_com
              puts "Reader Found on #{com}"
            end
            @connected = true
          rescue Exception
            if @debug_com
              puts "No Reader on #{com}"
            end
            raise 'Unable to connect to reader using default linux descriptor.'
          end
        
        else #Nothing to do...
        
          puts "Unknown operating system."
          raise 'Operating System Unknown. --Not sure how to find the reader...'
          
      end
      
    else
    
        #try connecting to what they give us...
        begin
          super(com)
          puts "Reader Found on #{com}"
          @connected = true
        rescue Exception
          p $!
          puts "No reader found on #{com}."
          raise 'Unable to connect to reader using supplied descriptor. --Is reader plugged in?'
        end
        
    end
        
    if @@methods_needed 
      build_methods(methodsfile) #see: methodbuilder.rb
      @@methods_needed = false
    end
  
    #Our interface has two modes: Synchronous command-response and streaming
    #The streaming interface is used when the reader is spinning, looking for tags
    #We need a flag to know how to treat data when in comes in on the serial port
    @reading_tags = false
      
    @tag_list = ThinkifyTagList.new
    
    #mutex so rx_buf doesn't get screwed up w/ multi-threaded access
    @taglist_mutex = Mutex.new
    
    @reading_tags=false
    
#    begin
#      send_receive("") #This will die if we failed to initialize properly...
#      @connected = true
#    rescue 
#      @connected = false
#    end
  end
  
  
private  

  
  #Override the parent routine in serialconnection. If there's a line of text in the serial receive buffer, this routine will be called with a marker to the first \r\n
  def process_rx_buf()
    
    #If we're in streaming mode, grab the data as it comes in. Otherwise, just wait for the receive function in SerialConnection to deal with it.            
    if @reading_tags  
      
        #data_received @rx_buf
      
    	  line_marker = @rx_buf.index("\r\n")
    	  data_to_process=""
    	  
    		while !line_marker.nil? do
    		  
	      	#puts "line marker: #{line_marker}"
	      	#puts @rx_buf
	      	  
	      	#there's at least one line of data in the rx_buf. Give someone a chance to do something with it...
	      	data_to_process << @rx_buf[0..(line_marker+1)]
	      	temp=@rx_buf[(line_marker+2)..@rx_buf.length]
	      	@rx_buf = temp
	      	line_marker = @rx_buf.index("\r\n")
	      end
	      	
      	if data_to_process !="" 
      		#puts "data_to_process #{data_to_process}"
      		@tag_list.update(data_to_process)  	
      		data_received data_to_process
      	end

    end
  
  end

  def process_rx_buf_orig(line_marker)
    
    #If we're in streaming mode, grab the data as it comes in. Otherwise, just wait for the receive function in SerialConnection to deal with it.            
    if @reading_tags  
      
      temp = ""
      #puts "before"
      #p @rx_buf
      
      
      @mutex.synchronize{
        temp = @rx_buf[0..(line_marker)]
        @rx_buf=@rx_buf[(line_marker+2)..@rx_buf.length]
      } 		  	
      		
      		
			#puts "after"
			#p @rx_buf
      @tag_list.update_line(temp)

    end
  
  end
    
public 
 
  #Send a command to the reader and return the response. If reading, pause while we execute the command and recommence afterwards.
  def execute(s)
    
    reply = ""
    
    if self.reading_active    	
       self.reading_active=false   
       reply= super(s)  
       #self.reading_active=true       
    else  
      #puts "in execute"
      #p s
          
      if s.upcase==("T6")
        self.reading_active=true
        reply=""
      else
        reply= super(s)    
      end   
    end 
    
    #fire the event
    data_received reply
    return reply   

  end
  
  
  #Set the reader to mask on a particular tag EPC or portion thereof.
  def epc_mask(t,ptr='20')
  #Say we want to mask on the first part of the EPC code of this tag.  "BBAA" (3000 is the PC word) Recall the Command Structure: 
  # M + 
  # NUM + 
  # ACTIVE + 
  # TTYPE + 
  # ACTION + 
  # MEMBANK + 
  # LEN(1 byte 2 nibbles)+
  # EBV(1 byte 2 nibbles MIN) +
  # DATA
  # 
  # To Set Mask 0 to look for “BAAA” in the right position we say:
  # 
  # M + '0'(mask) + '1'(enable) + '0'(ttype) + '0'(action)+ '1' (epc) + '10' (16 bits) + '20'(pointer) + 'BBAA' (data)
  # 
  # Our command should be: 
  # 
  # M010011020BBAA
  
    #strip out spaces...
    t.gsub!(" ","")

    if t=="-1"
      #clear the masks...
      mask_cmd="mr"
      execute(mask_cmd)
      reply = "Mask cleared."
    else
      mask_cmd = "M01001#{"%02x"%(t.length*4)}#{ptr}#{t}"
      reply = execute(mask_cmd)
    end
 
    return reply 
   
  end
  
  
  def clear_epc_mask
    self.epc_mask("-1")
  end
  
  
  #Clear the mask, do a quick inventory and return the strongest tag found. (The one with the highest RSSI value)
  def find_strongest_tag()
   
    self.clear_epc_mask
    self.clear_tag_list  
    tl = self.acquire #find out what's out there...

    if tl.length>0 

      strongest = tl[0]   

      tl.each do |t|

        if t.rssi > strongest.rssi
         strongest = t
        end    
        
      end     
     
      return strongest  
       
    else

      return nil

    end 
  
  end
  
  
  # find the tag in the field w/the highest RSSI value and set the current mask to that tag. -- used in program_epc.
  def mask_strongest_tag()
  
    strongest = self.find_strongest_tag
    
    #p strongest   
    
    if strongest.nil? 
      return false
    end
    
    #Strongest will have the PC word in front. mask from it...
    self.epc_mask(strongest.epc,'10') 
     
    return true          
    
  end
  
  #Program data into the tag. 
  def program( data="1111", membank=1, offset = "00", mask_strongest=true)
    
      # An idea... Mask the strongest tag we see in the field. This is good for 
    # single tag programming in the presence of other tags a little away from 
    # the antenna...   
    if mask_strongest
      self.mask_strongest_tag
    end
    
    #Strip spaces...
    data.gsub!(" ","")
    words_to_program = data.length/4
    
    
    # Our reader has the option to do multiple write operations at once... 
    # kinda cool, but I'm going to limit it to one in this function...
    if self.version > "1.3.3"
      #Newer Firmware: Enable the write descriptor =3 to allow change of pc word.
      if membank==1 #programming epc offset data by 2 words
        sr=execute("xw03#{membank}#{words_to_program}02#{data}")
      else
        sr=execute("xw03#{membank}#{words_to_program}#{offset}#{data}")
      end
      
    else
      #Older Firmware: Enable the write descriptor =2 to allow change of pc word.
      if membank==1 #programming epc offset data by 2 words
        sr=execute("xw02#{membank}#{words_to_program}02#{data}")
      else
        sr=execute("xw02#{membank}#{words_to_program}#{offset}#{data}")
      end
      
    end
    
    #make up to three attempts
    sr=execute("t61")
    
    if sr.include?("XWR0=SUCCESS")
      retvalue=true
    else
      retvalue=false
    end
    
    #Disable programming.
    sr=execute("xw00")
    
    if mask_strongest
      self.clear_epc_mask
    end

    return retvalue
      
  end
  
  
  #Program a large hunk of user memory from a hex string
  def program_user_big(data, mask_strongest=true)
  
    puts "data to program: #{data}"
    
    # An idea... Mask the strongest tag we see in the field. This is good for 
    # single tag programming in the presence of other tags a little away from 
    # the antenna...
    

    if mask_strongest
      self.mask_strongest_tag
    end
    
    #We'll program in 8-word or less chunks at these addresses...
    offset =["00","08","10","18","20","28","30","38","40","48","50","58","60","68","70","78"]
    
    #Strip spaces...
    data.gsub!(" ","")
    
    bytes_to_program = data.length / 2
    
    words_to_program = data.length / 4
    
    num_chunks = words_to_program / 8 #(can program 8 words at a time)
    
    0.upto(num_chunks).step(4) do |chunk|
    
      str_chunk_0 = data[(chunk * 32)..(chunk * 32 + 32)]
      str_chunk_1 = data[((chunk+1) * 32)..((chunk+1) * 32 + 32)]
      str_chunk_2 = data[((chunk+2) * 32)..((chunk+2) * 32 + 32)]
      str_chunk_3 = data[((chunk+3) * 32)..((chunk+3) * 32 + 32)]

      
      puts "chunk 0 #{str_chunk_0 }"
      puts "chunk 1 #{str_chunk_1 }"
      puts "chunk 2 #{str_chunk_2 }"
      puts "chunk 3 #{str_chunk_3 }"
      
      foo = false 
      if (foo)
        if str_chunk_0 !=""
            sr=execute("xw033#{str_chunk_1.size/4}#{offset[chunk]}#{str_chunk_1}")
        end
        if str_chunk_1 !=""
            sr=execute("xw133#{str_chunk_2.size/4}#{offset[chunk+1]}#{str_chunk_2}")
        end      
        if str_chunk_2 !=""
            sr=execute("xw233#{str_chunk_3.size/4}#{offset[chunk+2]}#{str_chunk_3}")
        end
        if str_chunk_3 !=""
            sr=execute("xw333#{str_chunk_4.size/4}#{offset[chunk+3]}#{str_chunk_4}")
        end 
      end
      
    end

  end
  
  
  #Program data into the tag. 
  def program_user_4( data=["1111","2222","3333","4444"], membank=3, offset = ["00","08","10","18"], mask_strongest=true )
    
    # An idea... Mask the strongest tag we see in the field. This is good for 
    # single tag programming in the presence of other tags a little away from 
    # the antenna...   
    

    if mask_strongest
      self.mask_strongest_tag
    end
    
    #Strip spaces...
    data.each do |entry|
      if entry
        entry.gsub!(" ","")
      end
    end
    
    words_to_program = data[0].length/4
    
    # Our reader has the option to do multiple write operations at once... 
    # kinda cool, but I'm going to limit it to one in this function...
    
    if self.version > "1.3.3"
      #Newer Firmware: Enable the write descriptor =3 to allow change of pc word.
      if membank==1 #programming epc offset data by 2 words
      else
        if data[0] 
          sr=execute("xw03#{membank}#{words_to_program}#{offset[0]}#{data[0]}")
        end
        if data[1] 
          sr=execute("xw13#{membank}#{words_to_program}#{offset[1]}#{data[1]}")
        end
        if data[2] 
          sr=execute("xw23#{membank}#{words_to_program}#{offset[2]}#{data[2]}")
        end
        if data[3] 
          sr=execute("xw33#{membank}#{words_to_program}#{offset[3]}#{data[3]}")
        end
        
      end
      
    else
      raise "Function not supported on older firmware"
    end
    

    #make up to three attempts
    sr=execute("t61")
    
    if sr.include?("XWR0=SUCCESS")
      retvalue=true
    else
      retvalue=false
    end
    
    #Disable programming.
    sr=execute("xwr")
    
    if mask_strongest
      self.clear_epc_mask
    end

    return retvalue
      
  end
  
  
  def program_epc(newepc="111122223333444455556666",mask_strongest=true)
    program(newepc,1,mask_strongest)
  end
  
  def program_user(data="1111", offset = "00", mask_strongest=false)
    program(data,3,offset, mask_strongest)
  end
  
  
  
  #Perform a quick, synchronous inventory and return a taglist w/the results.
  def acquire 
    tl = ThinkifyTagList.new
    sr=execute("t61")
     @tag_list.update(sr)
    tl.update(sr)
    return @tag_list
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
   
    if newvalue and !@reading_tags then
      #Turn on Polling...
      @reading_tags = true   
      send("t6") #start reading... 
    else  
      #Turn off Polling...
      @reading_tags=false     
      send_receive("")
    end
    
  end
  
  
end

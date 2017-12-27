=begin rdoc
= 
==thinkifytag.rb	

A simple class to hold taglist data elements. 

Allows construction of Tag objects from strings sent by the Thinkify TR50/TR200 Readers.

Copyright 2011, Thinkify, LLC. All rights reserved.
=end

require 'date'

# A storage class for RFID tag data elements.
class ThinkifyTag

  #By mixing in Comparable we can easily sort arrays of tags.
  include Comparable

  attr_accessor :epc    # EPC code of the tag that was read
  attr_accessor :ant   # Antenna on which the last read was made
  attr_accessor :count # Number of times the tag has been read since discovery
  attr_accessor :disc  # Time of discovery
  attr_accessor :last  # Time of latest read
  attr_accessor :rssi  # Signal Strength of tag read. 
  attr_accessor :freq  # Frequency of Tag Read
  attr_accessor :reported # A little flag for developers to know if they've done something with this tag.
  attr_accessor :xrdata #read descriptor responses
  attr_accessor :xwdata #write descriptor responses
  attr_accessor :xcmd #command descriptor responses
  

  
  # Create a tag from a string
  def initialize(taglist_entry="")
    @xrdata=["","","",""] 
    @xwdata=["","","",""]
	@xcmd=["","","",""]
    create(taglist_entry)
  end
  

# Return the contents of the tag object as a string (returns tag *id* as a string) 
  def inspect
    @epc.to_s
  end
  

# The 'spaceship' operator allows us to compare tags for sorting, etc.
  def <=>(s)
    @epc <=> s.epc
  end
  

# Returns a printable version of the tag object (returns tag *id* as a string) 
  def to_s
    @epc.to_s
  end
  

# Try to parse a string into a set of Tag object variables.
  def create(taglist_entry="")
    
    if taglist_entry.include?("TAG=") 	
      
      if taglist_entry.include?("TTAG")	  
        puts"***"
      end

      data = taglist_entry.split(" ") 
      
      #gotta be the right format to properly parse the result
      unless data.length == 7 
        p taglist_entry
        return nil
      end
      
      @epc = data[0].split("=")[1]
      
      #Format the EPC
      max = (@epc.length/4)-1
      
      1.upto(max) do |pos|
        @epc.insert(pos*5-1," ")
      end
      
      #Frequency			
      @freq = data[1].to_f / 1000
      
      #RSSI calc from AM datasheet
      if data[4].hex > data[3].hex
        high_rssi=data[4].hex
      else
        high_rssi=data[3].hex
      end       
      
      delta_rssi= (data[4].hex-data[3].hex).abs        
      
      @rssi =  2 * high_rssi + 10 * Math.log(1 + 10**(-delta_rssi/10)) # they include: -G-3 where G is some output power factor in dBm.
    
      @last = DateTime.now.strftime("%Y/%m/%d %H:%M:%S.%L") #Time out to milliseconds.
      @disc = last  		
      @count = 1
      @ant   = 0
      @reported = false     

      return self
    
	end 
	
  if taglist_entry==""
    
	  #make an empty structure...
		@epc = ""
		@freq = 0
	  @rssi = 0.0
		@last = DateTime.now.strftime("%Y/%m/%d %H:%M:%S.%L") #Time out to milliseconds.
		@disc = last  		
		@count = 0
		@ant   = 0
		
		@reported = false
		return self
	end
	
	return nil
        
  end

# Updates an existing tag object from another (new) one by incrementing the *count* and setting the new *last* time
  def update(new_tag)
    
    # Copy the last timestamp and increment the counts
    @last      = new_tag.last
    @count    += new_tag.count.to_i
    #TODO: Think about updating RSSI here w/an averaging function rather than a replacment
    @rssi      = new_tag.rssi
    @freq      = new_tag.freq  
    @last_last = @last  
    
    begin
    0.upto(3) do |i|
      unless ((new_tag.xrdata[i]=="") or (new_tag.xrdata[i].include?("FAIL")) or (new_tag.xrdata[i].include?("ERROR")) )
        @xrdata[i] = new_tag.xrdata[i]
      end
    end
	0.upto(3) do |i|
      unless ((new_tag.xcmd[i]=="") or (new_tag.xcmd[i].include?("FAIL")) or (new_tag.xcmd[i].include?("ERROR")) )
        @xcmd[i] = new_tag.xcmd[i]
      end
    end



    rescue
      puts $!
    end
    
    
  end
  
    
#**********************************************************************************
#'Bump an EPC (Hex string) by one
#'**********************************************************************************
  def increment_epc(strEPC, position)
  #'Let's do it recursively...
   
      strResult = strEPC
      
      if ((position >= 0) && (position < strEPC.length))
       
          
        intValue = strEPC[position].hex.to_i
        
        if ((intValue + 1) > 15)
        
            strEPC[position] = "0"
            position = position - 1
            strResult = increment_epc(strEPC, position)
         
        else
        
            strEPC[position] = (intValue + 1).to_s(16) 
            strResult = strEPC
        end
  
      end  
      
      return strResult
    
  end  
  
  
end

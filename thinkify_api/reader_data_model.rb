require 'json'

#*******************************************************************************
class TagObservation
  
  attr_accessor :epc
  attr_accessor :observed_time #when the data was read out of the tag...
  attr_accessor :config
   
  def initialize
    @data=[]
    @config={}
  end
  
  def to_json(*a) 
    {
      :epc=>@epc,
      :observed_time=>@observed_time.strftime("%Y-%m-%d %H:%M:%S"),
      :config=>@config,
      :data=>@data  
    }.to_json(*a)
  end
  
end


#*******************************************************************************
class TemperatureReport
  
  attr_accessor :epc
  attr_accessor :observed_time #when the data was read out of the tag...
  attr_accessor :config
   
  def initialize
    @data=[]
    @config={}
  end
  
  def add_reading(time, temp)
    @data.push( {:time=>time.strftime("%Y-%m-%d %H:%M:%S"), :temp=>temp})
  end
  
  def to_json(*a) 
    {
      :epc=>@epc,
      :observed_time=>@observed_time.strftime("%Y-%m-%d %H:%M:%S"),
      :config=>@config,
      :data=>@data  
    }.to_json(*a)
  end
  
end

#*******************************************************************************
class ReadPoint 
  attr_accessor :name
  attr_accessor :number
  attr_accessor :description
  attr_accessor :gps_location
  attr_accessor :data
 
  def initialize 
    @data =[]
  end
  
  def to_json(*a)
    {
      :name=>@name,
      :number=>@number,
      :description=>@description,
      :gps_location=>@gps_location,    
      :data=>@data
    }.to_json(*a)
  end

end

#*******************************************************************************
class ReaderData 
  #the reader that makes this report
  attr_accessor :name
  attr_accessor :mac #will be used to make a new reader, if needed
  attr_accessor :description
  attr_accessor :gps_location
  attr_accessor :readpoints
  attr_accessor :num_readpoints


  def initialize
    @readpoints = []   
  end
  
  def to_json(*a)
    {
      :name=>@name,
      :mac=>@mac,
      :gps_location=>@gps_location,
      :description=>@description,
      :num_readpoints=>@num_readpoints,
      :readpoints=>@readpoints  
    }.to_json(*a)
  end
  
end






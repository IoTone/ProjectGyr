=begin rdoc
=Thinkify Program Configuration Parser
==thinkifyconfig.rb	

A class to load/save application configuration data in a simple text file ala a windows .ini file.

Configuration parameters are maintained as a hash for the developer.

Copyright 2010, Thinkify, LLC. All rights reserved.
=end


class ThinkifyConfig < Hash
    
    def initialize(fn)
      super(nil)     
      load(fn)          
    end
    
    
    #Open a file and read out the configuration parameters. Save into a hash structure.
    #Blank lines and comment lines, beginning with '#' are ignored.
    def load(fn)
            
      if File.file?(fn)
        
        begin
            
            File.open(fn).each do |line|             
              #peel off terminators/leading spaces, etc.
              line.strip!        
              #ignore comment lines...
              if (line[0..0]!="#")              	
                keyval = line.index("=") # split on equal sign               
                #ignore blank lines
                unless keyval.nil? 
                    key       = line[0..(keyval-1)].strip.to_sym
                    value     = line[(keyval+1)..line.length].strip
                    self[key] = value
                end               
              end              
            end
            
        rescue 
          
          raise "Error: trouble loading data from file: #{fn}.\nDetails: #{$!}"
          
        end
      
      else
        
        raise "Error: cannot find configuration file: #{fn}.\nDetails: File not found."
          
      end  
        
    end
    
    
    #Save the hash data to a file.
    def save(fn)
    
        begin
          
          File.open(fn,"w") do |file|          
            output = ""           
            self.sort           
            self.each do |key, value|
              output << key.to_s + "=" + value.to_s + "\n"            
            end           
            file.print output           
            file.close         
          end
          
        rescue
          
          raise "Error: trouble saving configuration file: #{fn}.\nDetails: #{$!}"
          
        end
       
    end
    
  
end
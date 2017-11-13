=begin rdoc
=Method Builder Module
==MethodBuilder.rb	

Method builder provides functions to dynamically add methods to classes. ThinkifyReader uses this module to make developer friendly methods for reader settings, read from a file. 

See: readermethods.dat.

Copyright 2011, Thinkify LLC. All rights reserved.
=end


module MethodBuilder
  
  def add_get(name,cmd)
    #puts "building get #{name}"
    method_name = name.to_sym
    self.class.instance_eval { 
      send :define_method, method_name do |*val|     
        if val.nil? || val.size==0
          execute("#{cmd}")  
        else
          #puts "sending val"
          execute("#{cmd}#{val.to_s}")   
        end    
      end	
    }
  end
    
  def add_set(name,cmd)
    #puts "building set #{name}"
    method_name = (name+"=").to_sym
    self.class.instance_eval {
      send :define_method, method_name do |val|	
        begin
          execute("#{cmd}#{val.to_s}") 	
        rescue
          raise "Trouble setting #{name} to #{val}. Out of range?"
        end
      end
    }
  end

  def add_do(name,cmd)
    method_name = name.to_sym
    self.class.instance_eval { 
      send :define_method, method_name do |*val|
        if val.nil? || val.size==0     
          execute("#{cmd}")
        else
          execute("#{cmd}#{val.to_s}")   
        end    
      end
    }
  end
  
  def add_do_set(name,cmd)
    method_name = name.to_sym
    self.class.instance_eval {
      send :define_method, method_name do |val|	
        if val.nil? || val.to_s.size==0        
          execute("#{cmd}") 	
        else
          execute("#{cmd}#{val.to_s}") 	
        end    
      end
    }
  end  
  
  
  def add_getset(method_name,cmd)
    add_get(method_name,cmd)
    add_set(method_name,cmd)
  end
  
  #Build lots of the simple get/set methods supported by the class from a configuration file. No real error checking here. will blow up w/ a poorly formatted input file!
  private 
  def build_methods(fn)
    #puts "building methods from: #{fn}"
    #open the file and read out the methods to be supported  
    if File.file?(fn)
    	
      File.open(fn).each do |line|
      	
        if (line[0..0]!="#")
    
          dat = line.strip.split
          
          #ignore blank lines
          if dat.size>0 
          	       
            method_name = dat[0].strip #how we'll call it from code.
            cmd         = dat[1].strip  #protocol command 
            use         = dat[2].strip  #type: get/set/do
            
            #puts "Method: #{dat[0]} Use: #{dat[2]}"
            
            case use.downcase
              when "getset"
                add_getset(method_name,cmd)
              when "get"
                add_get(method_name,cmd)
              when "set"
                add_set(method_name,cmd)
              when "do"
                add_do(method_name,cmd)
              when "doset"
                add_do_set(method_name,cmd)
            end
            
          end
          
        end
        
      end
      
      @@methods_needed = false
      
    else
    	
      raise "Error: cannot find method definition file: #{fn}."
      
    end
    
  end
  
end

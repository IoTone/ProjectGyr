=begin rdoc
Little module to expose callback functionality from a class

usage:

  class Rumor 
    extend Callbacks
    
    callback :bigfoot_seen
    callback :elvis_seen
  ...
    def search
      ...
      if elvis
        elvis_seen location
      end
      if bigfoot 
        bigfoot_seen location
      end
      ...
    end
  end
  
  class NationalEnquirerReporter
    def initialize 
      ...
      myRumor = Rumor.new
      
      myRumor.bigfoot_seen do |loc|
        puts "Bigfoot was seen at #{loc}!"
      end
      
      myRumor.elvis_seen do |loc|
        puts "Elvis was seen at #{loc}!"
      end	
      ...
    end
  end
  
=end

module Callbacks
  def callback(*names)
    names.each do |name|
      class_eval <<-EOF
        def #{name}(*args, &block)
          if block
            @#{name} = block
          elsif @#{name}
            @#{name}.call(*args)
          end
        end
      EOF
    end
  end
end

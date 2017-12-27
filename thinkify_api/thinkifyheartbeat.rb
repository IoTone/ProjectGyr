#Heartbeat Service Compatible with the Alien Reader.
require 'rubygems'
require 'macaddr'
require 'socket'

class ThinkifyHeartbeat

  def initialize(port)
    
    @addr = ['<broadcast>',port]
    @socket = UDPSocket.new
    @socket.setsockopt(Socket::SOL_SOCKET, Socket::Socket::SO_BROADCAST,true)
  
    build_heartbeat_message
          
  end
  
  
  def start
    
    @hbthread = Thread.new{
      while true  
        @socket.send(@heartbeat_message, 0, @addr[0], @addr[1])
        sleep(@heartbeat_time)   
        #puts "#{Time.now}:  Sent Heartbeat!"
      end
    }
           
  end
  
  
  def build_heartbeat_message
    @readername="Thinkify RFID Reader"
    @readertype="TR-200 Desktop RFID Reader"
    @ipaddress = IPSocket.getaddress(Socket.gethostname)
    @heartbeat_time= 10
    @macaddress = Mac.addr.gsub("-",":")

    
    @heartbeat_message=""
      
@heartbeat_message=<<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<Alien-RFID-Reader-Heartbeat>
  <ReaderName>#{@readername}</ReaderName>
  <ReaderType>Alien RFID Tag Reader, Model: ALR-9900 (Four Antenna / Gen 2 / 902-928 MHz)</ReaderType>
  <IPAddress>#{@ipaddress}</IPAddress>
  <CommandPort>23</CommandPort>
  <HeartbeatTime>#{@heartbeat_time}</HeartbeatTime>
  <MACAddress>#{@macaddress}</MACAddress>
  <ReaderVersion>1.2.3</ReaderVersion>
</Alien-RFID-Reader-Heartbeat>
EOS
      #<ReaderType>#{@readertype}</ReaderType>
    

    
  end

end

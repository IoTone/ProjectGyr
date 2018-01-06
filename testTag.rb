class Testtag

  attr_accessor :epc, :rssi, :count, :disc, :last

  def initialize(epc, rssi, count, disc, last)
    @epc = epc
    @rssi = rssi
    @count = count
    @disc = disc
    @last = last
  end

end

# tag = Testtag.new("3000 3708 3371 DDD9 0440 0000 0100", "24.95310179804325", 33, "2017/12/22 14:26:48.755", "2017-12-22T15:15:34+00:00")

# { "_id" : ObjectId("5a3d5c79b7e24d2328000002"), "count" : 33, "epc" : "3000 3008 33B2 DDD9 0140 0000 0000", "discovery" : "2017/12/22 14:26:48.755", "rssi" : "24.95310179804325", "last_tag_read" : "2017-12-22T15:15:34+00:00", "time_difference" : 48, "read" : 2 }

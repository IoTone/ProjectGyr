class Tag
  include MongoMapper::Document
  self.partial_updates = true

  key :count, Integer
  key :epc, String
  key :discovery, String
  key :rssi, String
  key :last_tag_read, String
  key :time_difference, Integer
end

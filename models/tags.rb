class Tag
  include MongoMapper::Document

  key :count, Integer
  key :epc, String
  key :discovery, String
  key :rssi, String
  key :last_tag_read, String
end

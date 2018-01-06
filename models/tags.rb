class Tag
  # include MongoModule

  attr_accessor :_id, :epc, :count, :rssi, :discovery, :last_tag_read, :time_difference, :read

  # def init_collection
  #   self.collection = 'tags'
  # end

end

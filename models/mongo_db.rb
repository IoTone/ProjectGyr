require 'mongo_mapper'

#Creating a connection to database

MongoMapper.connection = Mongo::Connection.new('localhost')

MongoMapper.database = "tagdata"

require 'mongo_mapper'
require './models/tags.rb'
#Creating a connection to database

MongoMapper.connection = Mongo::Connection.new('localhost')

MongoMapper.database = "tagdata"

require 'mongo'
require './models/mongoModule.rb'
require './models/tags.rb'
#Creating a connection to database

CONNECTION = Mongo::Connection.new('localhost')

DB = CONNECTION.db('tagdata')

TAGS = DB['tags']

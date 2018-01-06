require 'mongo'
require './models/mongoModule.rb'
require './models/tags.rb'
#Creating a connection to database

# CONNECTION = Mongo::Connection.new('localhost')

client = Mongo::Client.new([ 'localhost' ], :database => 'tagdata')

db = client.database

TAGS = client[:tags]

puts TAGS.inspect

# DB = CONNECTION.db('tagdata')
#
# TAGS = DB['tags']

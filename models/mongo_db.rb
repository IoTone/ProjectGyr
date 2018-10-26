require 'mongo'
require './models/mongoModule.rb'
require './models/tags.rb'
require './models/repeats.rb'
require './models/reads.rb'
#Creating a connection to database

# CONNECTION = Mongo::Connection.new('localhost')

client = Mongo::Client.new([ 'localhost' ], :database => 'tagdata')

db = client.database

TAGS = client[:tags]
READS = client[:reads]
REPEATS = client[:repeats]

puts TAGS.inspect

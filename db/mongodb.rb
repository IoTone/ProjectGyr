require 'mongo'
require './models/tags'

#Creating a connection to database
client = Mongo::Client.new(['127.0.0.1:27017'], :database => 'test')

puts "#{client.cluster.servers.inspect}"

# Overview

# Project Gyruss v.1

A simple Sinatra app that connects to Thinkify API for TR-265 to record and log visits of RFID stickers

## Technology

Ruby 2.4.2 (https://rvm.io/ RVM is recommended as a way to install on Linux)

Sinatra 2.0.0

MongoDB Ruby Driver 2.4 https://docs.mongodb.com/ruby-driver/master/

MongoMapper 0.14.0 http://mongomapper.com/

Thinkify API TR-265 Reader

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

Make sure refer to Thinkify TR-265 setup guide to install proper drivers 

Also, to run bundler you must install its gem. You can do this by entering this in terminal:

```
sudo gem install bundler
```

Refer to bundler article if needed:

https://help.dreamhost.com/hc/en-us/articles/115001070131-Using-Bundler-to-install-Ruby-gems


Bundler wont run effectively on linux due to incompatibilites with Nokogiri. To resolve these issues, run this command to install proper configuration:

```
sudo apt-get install build-essential patch ruby-dev zlib1g-dev liblzma-dev
sudo gem install nokogiri
```

Refer to Nokogiri docs for more info: http://www.nokogiri.org/tutorials/installing_nokogiri.html

### Installing

To run the development environment, just clone the repo and in the directory do these steps:

Run bundle

```
bundle install
```

Running this will get all the dependencies installed and ready for starting the application

### Run a server

Run instance of MongoDB server by navigating to your mongo directory and run:

```
./mongod.exe
```

After getting the app onto your machine and running mongo server, in the project directory run:

```
rackup
```

Then go to your browser and type in (May very depending on what port WEBRICK grabs):

```
http://localhost:9292/ 
```





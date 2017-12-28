# Overview

# Project Gyruss v.1

A simple Sinatra app that connects to Thinkify API for TR-265 to record and log visits of RFID stickers

## Technology

Ruby 2.3.0

Sinatra 2.0.0

MongoDB Ruby Driver and MongoDB with MongoMapper

Thinkify API TR-265 Reader

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

Make sure refer to Thinkify TR-265 setup guide to install proper drivers

### Installing

To run the development environment just clone the repo and in the directory do these steps:

Run bundle

```
bundle install
```

### Run a server

Run instance of MongoDB server by navigating to your mongo directory and run:

```
./mongod.exe
```

After getting the app onto your machine and running mongo server, in the project directory run:

```
rackup
```

Then go to your browser and type in (May very depending on what port that WEBRICK grabs):

```
http://localhost:9292/ 
```




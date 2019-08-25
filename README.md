![Alt text](./public/images/gyruss.png?raw=true "ProjectGyr")

![Alt text](./public/images/setting_page.png?raw=true "Settings")

# Overview

Project Gyr v0.9 provides an easy way to use RFID to detect presense and track users in an area.  The intent is to offer a realtime dashboard for anyone needing to track movement, checkins, walk ins, visits, etc., in a particular area around an RFID proximity reader.  

A simple Sinatra app that connects to Thinkify API for TR-265 to record and log visits of RFID stickers.  The reader part of the application spends cycles reading for new RFID tags, and then updating the backend system with updates such that any web based clients can see a realtime set of status updates in a dashboard.  In addition to a dashboard, the app provides a debugger and data export.

Why the name Gyr, because we love that 80's video game, Gyruss.

## Dependencies

Ruby 2.4.2 (https://rvm.io/ RVM is recommended as a way to install on Linux)

Sinatra 2.0.0

MongoDB Ruby Driver 2.4 https://docs.mongodb.com/ruby-driver/master/

MongoMapper 0.14.0 http://mongomapper.com/

Thinkify API https://drive.google.com/open?id=1JM289l5eTAna-oBwAmP4c0go3IegeyzL

## Hardware

- Thinkify TR-265 Reader https://thinkifyit.com/collections/rfid-readers/products/tr-265-usb-desktop-rfid-reader
- Thinkify Circularly Polarized Antenna https://thinkifyit.com/collections/antennas/products/tac-060-ip67-circularly-polarized-antenna

## Tags

Any standard RFID tag should work.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

Make sure to refer to Thinkify TR-265 setup guide to install proper drivers

Go to this link: https://drive.google.com/open?id=1JM289l5eTAna-oBwAmP4c0go3IegeyzL and download the Thinkify Developers Kit 2.2 Zip file

(If that link is broken, just go to https://thinkify.com/pages/downloads instead)

From there, go to the Documents folder and follow the TR-265 Driver Guide to install thinkify's reader driver

Once you have that installed, go to the Software API's folder, click the Ruby folder, and place the thinkify_api folder at the root directory of Project

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

## Configuration

Any changes needed to configuration should go into gyruss_values.yml.

- linger_threshold: 5 (number of seconds)
- reader_duty_cycle: 3 (number of seconds to poll to red tags)
- reader_ID: Reader 129JDFALK
- serial_port: COM 12
- status_of_connection: Not Connected

## Daemons

TODO: Add info on setup of systemd units

### Run a server

Run instance of MongoDB server by navigating to your mongo directory and run:

```
./mongod.exe
```

After getting the app onto your machine and running mongo server, in the project directory run:

```
bundle exec rackup --host 0.0.0.0
```

Then go to your browser and type in (May very depending on what port WEBRICK grabs):

```
http://localhost:9292/
```

Run a reader service in a different shell:

```
ruby gyr_reader_tier.rb
```

## RFID and Your Research

This is a very interesting area to research, the area of localization (in terms of indoor positioning), user tracking, and analysis of movement of people or objects (packages).  If you have some research you'd like to do as a collaboration, please contact us at IoTone.  We have a number of specialists in this area through prior work of the founder with PARC, and there might be some overlap in areas of focus.  Feel free to use this code and improve upon it.

## RFID and Your Business

If you have need for equipment, tags, and business expertise around NFC and RFID, please contact our partner, http://tagstand.com.  We've worked with them for years, and they can help out small and medium sized business with solutions.

If you have specific development needs, please contact us.

## Contributions

We welcome pull requests, new issues, and will attempt to maintain this to meet the needs of the user community.

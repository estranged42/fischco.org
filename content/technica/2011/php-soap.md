---
author: Mark Fischer
title: "PHP SoapServer, Objects, Arrays, and encoding"
date: 2011-03-26T17:00:00-07:00
type: post
categories:
  - geek
  - code
  - article
aliases:
  - /blog/2011/3/26/php-soapserver-objects-arrays-and-encoding.html

---

I ran into an bothersome problem with PHP's [SoapServer][] class this week.

[SoapServer]: http://php.net/manual/en/class.soapserver.php

<!--more-->

Here's what I wanted as output from the server:

    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
       <SOAP-ENV:Body>
          <locationCollection>
             <Location>
                <name>AME s438</name>
                <id>452</id>
                <latitude>32.236322</latitude>
                <longitude>-110.951614</longitude>
             </Location>
             <Location>
                <name>ECE 229</name>
                <id>45</id>
                <latitude>32.235069</latitude>
                <longitude>-110.953417</longitude>
             </Location>
          </locationCollection>
       </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>


However what I was getting instead was: 

    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
       <SOAP-ENV:Body>
          <locationCollection>
             <SOAP-ENC:Struct>
                <name>AME s438</name>
                <id>452</id>
                <latitude>32.236322</latitude>
                <longitude>-110.951614</longitude>
             </SOAP-ENC:Struct>
             <SOAP-ENC:Struct>
                <name>ECE 229</name>
                <id>45</id>
                <latitude>32.235069</latitude>
                <longitude>-110.953417</longitude>
             </SOAP-ENC:Struct>
          </locationCollection>
       </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>

Here was my original code for the server:

    <?php
    $wsdl = 'http://example.com/locations_service.wsdl';
    $service = new SoapServer($wsdl);

    $service->addFunction('getComputerLabs');
    $service->handle();

    function getComputerLabs($input) {
      $all_locations = resource::get_all(FALSE, 'location');

      $return_array = array();

      foreach ($all_locations as $l) {

        // Build a basic return object.
        $new_loc = new Location();
        $new_loc->name = $l->name;
        $new_loc->id = $l->resource_id;
        $new_loc->latitude = $l->getProperty('Latitude');
        $new_loc->longitude = $l->getProperty('Longitude');

        $return_array[] = $new_loc;
      }

      return $return_array;
    }

    class Location {
        public $name;
        public $id;
        public $description;
        public $url;
        public $buildingName;
        public $roomNumber;
        public $openStatus;
        public $latitude;
        public $longitude;
    }
    ?>

Apparently the SOAP library really prefers that everything is an object.  In php 5 they added an [ArrayObject][] class.  This coupled with a SoapVar call fixed my output for me.

[ArrayObject]: http://www.php.net/manual/en/class.arrayobject.php

    <?php
    function getComputerLabs($input) {
      $all_locations = resource::get_all(FALSE, 'location');

      /**
       * Use an ArrayObject instead of a plain array.
       */
      $return_array = new ArrayObject();

      foreach ($all_locations as $l) {

        // Build a basic return object.
        $new_loc = new Location();
        $new_loc->name = $l->name;
        $new_loc->id = $l->resource_id;
        $new_loc->latitude = $l->getProperty('Latitude');
        $new_loc->longitude = $l->getProperty('Longitude');

        /**
         * Encode each array element with SoapVar.  Parameter 5 is the name of the
         * XML element you want to use.  This only seems to work within
         * an ArrayObject.
         */
        $new_loc = new SoapVar($new_loc, SOAP_ENC_OBJECT, null, null, 'Location');

        $return_array->append($new_loc);
      }

      return $return_array;
    }
    ?>

Note that with only the ArrayObject part, and before I figured out the SoapVar wrapper, I was getting this interesting BOGUS tag:

    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
       <SOAP-ENV:Body>
          <locationCollection>
             <BOGUS>
                <name>AME s438</name>
                <id>452</id>
                <latitude>32.236322</latitude>
                <longitude>-110.951614</longitude>
             </BOGUS>
             <BOGUS>
                <name>ECE 229</name>
                <id>45</id>
                <latitude>32.235069</latitude>
                <longitude>-110.953417</longitude>
             </BOGUS>
          </locationCollection>
       </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>


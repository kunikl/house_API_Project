#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'snmp'
require 'fluent-logger'
require 'json'

necIXInternalTemperatureOID = "1.3.6.1.4.1.119.2.3.84.2.1.1.0"
arpcachetablesOID = "1.3.6.1.2.1.3.1.1.2"
cachetablesOID = "1.3.6.1.2.1.3.1.1.2"
Fluent::Logger::FluentLogger.open(nil, :host=>'133.242.144.202', :port=>19999)
id = "shibuhouse"

while(true) 
  clients = 0
  temperature = 0
    SNMP::Manager.open(:host=>'172.16.0.254', :community=>'public1', :version=>:SNMPv2c,) do |manager|

      #wifi connecting clients
      manager.walk(arpcachetablesOID) do |row|
        clients += 1
      end
        puts clients
    Fluent::Logger.post("shibuhouse.wifi.clients", {"id"=>"#{id}", "clients"=>"#{clients}"})

      #wifi temperture
    response = manager.get([necIXInternalTemperatureOID])
    response.each_varbind{|v|
        temperature = v.value.to_s
        puts v.value.to_s
      Fluent::Logger.post("shibuhouse.wifi.temperature", {"id"=>"#{id}", "temperature"=>"#{v.value.to_s}"})
    }

    Fluent::Logger.post("shibuhouse.wifi", {"id"=>"#{id}", "temperature"=>"#{temperature}", "clients" => "#{clients}"})
    sleep(10)
    end
end

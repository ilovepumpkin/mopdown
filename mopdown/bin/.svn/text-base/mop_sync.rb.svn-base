$:.unshift File.join(File.dirname(__FILE__), "../lib")
require 'service'
require 'config'

include Config

service=Service::FileDataService.instance
service.down_catalog('a'..'z',true)
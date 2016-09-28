require 'logger'

module Logging
  class MyLogger<Logger
    def initialize
      Dir.mkdir $log_dir unless File.exists? $log_dir
      super(File.join($log_dir,"mop_down.log")) 
    end
  end
end
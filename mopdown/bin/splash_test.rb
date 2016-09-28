$:.unshift File.join(File.dirname(__FILE__), "../lib")
require 'ui/tk/splash'
require 'ui/tk/util'
require 'config'

include Config

splash=TkUi::Splash.new
#~ TkUi::TkUtil.screen_center splash,400,300
#~ splash.geometry("600x450+300+10")
#~ splash.overrideredirect(0)
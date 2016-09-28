$:.unshift File.join(File.dirname(__FILE__), "../lib")
require 'ftools'
require 'util'

Dir.mkdir("tmp") unless File.exists?("tmp")

Dir.chdir("../bin")
system("ruby -r ../gen_exe/dependency.rb ../gen_exe/rubyscript2exe.rb mop_down.rb --rubyscript2exe-tk --rubyscript2exe-rubyw")

File.copy("mop_down.exe","../gen_exe/tmp/mop_down.exe")
Dir.chdir("../gen_exe/tmp")
system("mop_down.exe --eee-justextract")

ruby_tk_root="D:/opt/ruby/lib/ruby/1.8/tk"
File.copy(File.join(ruby_tk_root,"canvas.rb"),"./lib/tk/canvas.rb")
File.copy(File.join(ruby_tk_root,"canvastag.rb"),"./lib/tk/canvastag.rb")
File.copy(File.join(ruby_tk_root,"tagfont.rb"),"./lib/tk/tagfont.rb")
File.copy("../app.eee","app.eee")

system("eeew.exe app.eee mop_down.exe")

File.copy("mop_down.exe","../../bin/mop_down.exe")

Dir.chdir("..")
Util::FileUtil.instance.delete_dir("tmp")



require 'rubygems'
require 'rake/gempackagetask'

Dir.chdir("gen_exe")
system("ruby gen_exe.rb")

Dir.chdir("..")
spec = Gem::Specification.new do |s|
  s.name = 'mopdown'
  s.version = "0.9.5"
  s.author = "mopdown"
  s.email = "mopdown@gmail.com"
  s.homepage = "http://code.google.com/p/mopdown/"
  s.platform = Gem::Platform::RUBY
  s.summary = "A software to download and manage comic books"
  s.files = Dir.glob("{bin,lib,images,data}/**/*").delete_if { |item| 
    item.include?("logs")||item.include?("test_root") || item.include?(".exy") || item.include?(".ico") || item.include?("books") || item.include?("/cover") || item.include?("rubyscript2exe.rb")
  }
  s.require_path = 'lib'
  s.has_rdoc = 'false'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  #~ pkg.need_tar = true
end

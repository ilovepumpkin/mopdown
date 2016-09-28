module Config
$root_dir='../data'
$image_dir='../images'
$log_dir='../logs'

Dir.mkdir($root_dir) unless File.exist? $root_dir
Dir.mkdir $log_dir unless File.exists? $log_dir

end
require 'digest/md5'

script_path = File.dirname(__FILE__)
script_dir = File.expand_path(script_path)

repository_name = File.basename(Dir.pwd)
repository_hash = Digest::MD5.new.update(Dir.pwd).to_s
branch_name = 'master'
prev_file = "#{script_dir}/tmp/#{repository_name}-#{branch_name}-#{repository_hash}"

forwardlist = []
removelist = []

if ! File.exist?(prev_file) then
  puts 'not exist log file.'
  cmd = "git ls-files"
  responce_cmd = `#{cmd}`
  responce_cmd.each_line do |line|
    forwardlist << line.chomp
  end
  File.open(prev_file, 'a') do |file|
    str = "#{Time.now.to_s}\t#{`git rev-parse HEAD`}"
    file.puts(str)
  end
else
  puts 'exist log file.'
  prev_hash = ''
  head_hash = `git rev-parse HEAD`.chomp
  open("|tail -n 1 < #{prev_file}") do |fi|
    line = fi.gets(nil)
    strs = line.chomp.split("\t")
    prev_hash = strs[1]
  end
  if head_hash != prev_hash
    puts "Different hash"
    cmd = "git diff --name-status #{prev_hash} #{head_hash}"
    responce_cmd = `#{cmd}`
    responce_cmd.each_line do |line|
      strs = line.chomp.split("\t")
      case strs[0]
      when "A","M"
        forwardlist << strs[1]
      when "D"
        removelist << strs[1]
      end
    end
  else
    puts "Same hash."
    exit
  end
end

puts "Forward list ======"
p forwardlist
puts "Remove list ======="
p removelist

require 'digest/md5'

script_path = File.dirname(__FILE__)
script_dir = File.expand_path(script_path)

REPOSITORY_PATH = Dir.pwd
REPOSITORY_NAME = File.basename(REPOSITORY_PATH)
REPOSITORY_HASH = Digest::MD5.new.update(REPOSITORY_PATH).to_s
branch_name = 'master'

TMP_FILE = "#{script_dir}/tmp/#{REPOSITORY_NAME}-#{branch_name}-#{REPOSITORY_HASH}"

forwardlist = []
removelist = []

if ! File.exist?(TMP_FILE) then
  puts 'not exist log file.'
  cmd = "git ls-files"
  responce_cmd = `#{cmd}`
  responce_cmd.each_line do |line|
    forwardlist << line.chomp
  end
  File.open(TMP_FILE, 'a') do |file|
    str = "#{Time.now.to_s}\t#{`git rev-parse HEAD`}"
    file.puts(str)
  end
else
  puts 'exist log file.'
  prev_hash = ''
  head_hash = `git rev-parse HEAD`.chomp
  open("|tail -n 1 < #{TMP_FILE}") do |fi|
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
    File.open(TMP_FILE, 'a') do |file|
      str = "#{Time.now.to_s}\t#{head_hash}"
      file.puts(str)
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

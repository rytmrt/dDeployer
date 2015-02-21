require 'digest/md5'

SCRIPT_PATH = File.dirname(__FILE__)
SCRIPT_DIR = File.expand_path(SCRIPT_PATH)

BRANCH = 'master'
`git checkout #{BRANCH}`

REPOSITORY_PATH = Dir.pwd
REPOSITORY_NAME = File.basename(REPOSITORY_PATH)
REPOSITORY_HASH = Digest::MD5.new.update(REPOSITORY_PATH).to_s
REPOSITORY_HEAD = `git rev-parse HEAD`.chomp

TMP_FILE = "#{SCRIPT_DIR}/tmp/#{REPOSITORY_NAME}-#{BRANCH}-#{REPOSITORY_HASH}"

def create_list_object()
  return {:forward => [],:remove => []}
end

def get_diff_file_list(commit1, commit2)
  list = create_list_object()
  responce_cmd = `git diff --name-status #{commit1} #{commit2}`
  responce_cmd.each_line do |line|
    strs = line.chomp.split("\t")
    case strs[0]
    when "A","M"
      list[:forward] << strs[1]
    when "D"
      list[:remove] << strs[1]
    end
  end
  return list
end

def get_all_file_list()
  list = create_list_object()
  responce_cmd = `git ls-files`
  responce_cmd.each_line do |line|
    list[:forward] << line.chomp
  end
  return list
end

def get_last_hash(file)
  hash = nil
  open("|tail -n 1 < #{file}") do |fi|
    line = fi.gets(nil)
    strs = line.chomp.split("\t")
    hash = strs[1]
  end
  return hash
end

def deploy(deploy_info)
  do_deploy = false
  if deploy_info[:forward].count > 0 then
    puts "Forward list ======"
    p deploy_info[:forward]
    do_deploy = true
  end
  if deploy_info[:remove].count > 0 then
    puts "Remove list ======="
    p deploy_info[:remove]
    do_deploy = true
  end
  return do_deploy
end

def write_log(file, str)
  File.open(file, 'a') do |file|
    file.puts(str)
  end
end


# MAIN -------------------------------------------------------------------------
file_list = nil
if ! File.exist?(TMP_FILE) then
  puts 'not exist log file.'
  file_list = get_all_file_list()
else
  puts 'exist log file.'
  last_hash = get_last_hash(TMP_FILE)
  if REPOSITORY_HEAD != last_hash
    puts "Different hash"
    file_list = get_diff_file_list(last_hash, REPOSITORY_HEAD)
  else
    puts "Same hash."
    exit
  end
end

if deploy(file_list)
  write_log(TMP_FILE, "#{Time.now.to_s}\t#{REPOSITORY_HEAD}")
end

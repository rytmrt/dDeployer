# coding: utf-8

require 'yaml'
require 'net/ssh'
require 'net/sftp'
require 'ddeployer/constants'

module Ddeployer
  class Deploy
    def initialize repo
      @conf_dir = "#{APP_SAVE_DIR}/conf"
      @repository = repo

      @server_yaml = "#{@conf_dir}/server.yaml"
      @server_conf = load_yaml @server_yaml

      @ddeployer_yaml = "#{@repository.path}/ddeployer.yaml"
      @ddeployer_conf = load_yaml @ddeployer_yaml
    end

    def do files
      repo_conf = @ddeployer_conf[@repository.branch]
      local_path = repo_conf[:path][:local]
        .gsub(/^\.\/(.*)$/, "\\1")
        .gsub(/^(.*)\/$/, '\\1')
        .gsub(/^\.$/, "")
      if local_path != "" then
        files.forward = squeeze_file files.forward, local_path
        files.remove  = squeeze_file files.remove, local_path
      end
      remote_path = repo_conf[:path][:remote]
        .gsub(/^(.*)\/$/, '\\1')
      remote_files = files.clone
      local2remote_path remote_files.forward, local_path, remote_path
      local2remote_path remote_files.remove, local_path, remote_path
      host_tag = repo_conf[:host_tag]
      remote_conf = @server_conf[host_tag]
      remote = {
        :host => remote_conf[:host],
        :user => remote_conf[:user],
        :opt => {
          :port => remote_conf[:port]
        }
      }
      if remote_conf[:key] != nil then
        remote[:opt][:keys] = File.expand_path(remote_conf[:key][:path])
        if remote_conf[:key][:passphrase] != nil then
          remote[:opt][:passphrase] = remote_conf[:key][:passphrase]
        end
      else
        remote[:opt][:passwd] = remote_conf[:passwd]
      end
      file_prem = 0644
      dir_prem = 0755
      Net::SSH.start(remote[:host], remote[:user], remote[:opt]) do |ssh|
        remote_dirs = []
        remote_files.forward.each do |i|
          dir_path = File.dirname(i)
          remote_dirs << dir_path
        end
        remote_dirs.uniq!
        remote_dirs.each do |i|
          ssh.exec! "mkdir -p #{i}"
        end
        ssh.sftp.connect do |sftp|
          files.forward.zip(remote_files.forward).each do |l_item, r_item|
            if File.exist? l_item then
              sftp.upload!("#{@repository.path}\/#{l_item}", "#{r_item}", :permissions => file_prem)
              puts "+ #{l_item} > #{r_item}"
            else
              puts "Not exist '#{l_item}'"
            end
          end
          files.remove.zip(remote_files.remove).each do |l_item, r_item|
            puts "- #{l_item}"
            sftp.remove("#{@repository.path}\/#{l_item}", "#{r_item}").wait
          end
        end
      end
    end

    private
    def squeeze_file files, local_path
      files.select! do |x|
        x.match(/^#{local_path}\//) != nil
      end
      return files
    end

    private
    def local2remote_path files, local_path, remote_path
      files.collect! do |i|
        i = i.gsub(/^#{local_path}\/(.*)$/, "\\1")
          .gsub(/^(.*)$/, "#{remote_path}\/\\1")
      end
      return files
    end

    private
    def load_yaml yaml, ex_str=nil
      if File.exist?(yaml) then
        return YAML.load_file(yaml)
      else
        puts "Not exist '#{yaml}'"
        if ex_str != nil then
          puts "#{ex_str}"
        end
        exit
      end
    end

  end
end

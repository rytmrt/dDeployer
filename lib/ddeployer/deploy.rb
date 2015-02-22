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
        files.forward.select! do |x|
          x.match(/^#{local_path}\//) != nil
        end
        files.remove.select! do |x|
          x.match(/^#{local_path}\//) != nil
        end
      end

      # show list for debag
      files.forward.each do |item|
        puts "+ #{item}"
      end
      files.remove.each do |item|
        puts "- #{item}"
      end
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

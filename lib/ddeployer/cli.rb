# coding: utf-8

require 'thor'
#require 'ddeployer/'
require 'ddeployer/file_list'
require 'ddeployer/temporary'
require 'ddeployer/deploy'
require 'ddeployer/repository'

module Ddeployer
  class CLI < Thor
    default_command :"dry-run"
    class_option :branch, type: :string, aliases: '-b',default: 'master' , desc: 'branch name'

    desc 'lastlog', 'show log of when last execute.'
    def lastlog
      puts 'last revision'
      repo = Repository.new Dir.pwd, options[:branch]
      tmp = Temporary.new repo
      last = tmp.get_last
      if last != nil then
        puts "#{last[:time]}"
        puts "  -> #{last[:hash]}"
      else
        puts "not exit #{tmp.file}"
      end
    end

    desc 'log', 'Show deploy log'
    def log
      puts 'log'
      puts options[:branch]
    end

    desc 'dry_run', 'dry run'
    def dry_run
      e "DRY RUN"
      repo = Repository.new Dir.pwd, options[:branch]
      tmp = Temporary.new repo
      e tmp.file
      last = tmp.get_last
      if last != nil then
        if last[:hash] == repo.head then
          e 'No diff!'
          return
        end
        files = FileList::get_diff last[:hash], repo.head
      else 
        files = FileList::get_all
      end
      deploy = Deploy.new repo
      deploy.dry files
    end

    desc 'do_run', 'do deploy'
    def do_run
      puts 'DEPLOY'
      repo = Repository.new Dir.pwd, options[:branch]
      tmp = Temporary.new repo
      e tmp.file
      last = tmp.get_last
      if last != nil then
        if last[:hash] == repo.head then
          e 'No diff!'
          return
        end
        files = FileList::get_diff last[:hash], repo.head
      else 
        files = FileList::get_all
      end
      deploy = Deploy.new repo
      deploy.do files
      tmp.write_log repo.head
    end

    private
    def e s, c=:green
      say s, c
    end
  end
end
